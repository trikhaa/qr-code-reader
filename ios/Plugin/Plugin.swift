import Foundation
import Capacitor
import AVFoundation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(QRCodePlugin)
public class QRCodePlugin: CAPPlugin, AVCaptureMetadataOutputObjectsDelegate {
    
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    
    var previewView: UIView!
    var detectionArea: UIView!
    var codeView: UIView!
    var code: String!
    var type: String!
    
    var isReady = false
    
    var callFinal :CAPPluginCall!
    
    @objc func echo(_ call: CAPPluginCall) {
        
        let value = call.getString("value") ?? ""
        call.success([
            "value": value
        ])
    }
    
    @objc func scanCode(_ call: CAPPluginCall) {
        
        callFinal = call
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                let x: CGFloat = 0.05
                let y: CGFloat = 0.3
                let width: CGFloat = 0.9
                let height: CGFloat = 0.5
                
                if !self.isReady {
                    guard let videoDevice = AVCaptureDevice.default(for: .video) else {
                        self.failed(call: self.callFinal,message:"No Camera found")
                        return
                    }
                    let videoInput: AVCaptureDeviceInput
                    do {
                        videoInput = try AVCaptureDeviceInput(device: videoDevice)
                    } catch {
                        self.failed(call: self.callFinal,message:"Failed to init camera")
                        return
                    }
                    if (self.captureSession.canAddInput(videoInput)) {
                        self.captureSession.addInput(videoInput)
                    } else {
                        self.failed(call:self.callFinal,message:"Unable to add input")
                        return
                    }
                    let metadataOutput = AVCaptureMetadataOutput()
                    self.captureSession.addOutput(metadataOutput)
                    
                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    
                    metadataOutput.metadataObjectTypes = [
                        AVMetadataObject.ObjectType.qr,
                        AVMetadataObject.ObjectType.code39,
                        AVMetadataObject.ObjectType.ean13,
                    ]
                    metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
                    metadataOutput.rectOfInterest = CGRect(x: y,y: 1-x-width,width: height,height: width)
                    self.isReady = true
                }
                
                self.previewView = UIView()
                self.previewView.frame = rootViewController.view.bounds
                self.previewView.tag = 325973259 // rand
                rootViewController.view.addSubview(self.previewView)
                
                self.videoLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
                self.videoLayer?.frame = rootViewController.view.bounds
                self.videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.previewView.layer.addSublayer(self.videoLayer!)
                
                
                self.detectionArea = UIView()
                self.detectionArea.frame = CGRect(x: rootViewController.view.frame.size.width * x, y: rootViewController.view.frame.size.height * y, width: rootViewController.view.frame.size.width * width, height: rootViewController.view.frame.size.height * height)
                self.detectionArea.layer.borderColor = UIColor.red.cgColor
                self.detectionArea.layer.borderWidth = 3
                self.previewView.addSubview(self.detectionArea)
                
                self.codeView = UIView()
                self.codeView.layer.borderWidth = 4
                self.codeView.layer.borderColor = UIColor.red.cgColor
                self.codeView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
                self.codeView.addGestureRecognizer(tapGesture)
                
                self.previewView.addSubview(self.codeView)
                
                let btnClose = UIButton()
                btnClose.titleLabel?.textAlignment = .center
                btnClose.setTitle("✕", for: .normal)
                btnClose.setTitleColor(.white, for: .normal)
                btnClose.frame = CGRect(x: 20, y: 30, width: 30, height: 30)
                btnClose.layer.cornerRadius = btnClose.bounds.midY
                btnClose.backgroundColor = .black
                
                btnClose.tag = 327985328732 // rand
                rootViewController.view.addSubview(btnClose)
                
                let closeGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeGesture))
                btnClose.addGestureRecognizer(closeGesture)
                
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if !self.captureSession.isRunning {
                        self.captureSession.startRunning()
                    }
                }
            }
        }
    }
    
    @objc func tapGesture(sender:UITapGestureRecognizer) {
        NSLog("CAP: TAP" +  self.code)
    }
    
    @objc func closeGesture(sender:UITapGestureRecognizer) {
        self.closeScanner()
    }
    
    public func closeScanner() {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                self.codeView.isUserInteractionEnabled = false
                rootViewController.view.isUserInteractionEnabled = true
                if let previewView = rootViewController.view.viewWithTag(325973259) {
                    previewView.removeFromSuperview()
                }
                if let btnClose = rootViewController.view.viewWithTag(327985328732) {
                    btnClose.removeFromSuperview()
                }
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                }
            }
        }
    }
    
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            if metadata.stringValue != nil {
                let barCode = self.videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                if barCode.bounds.height != 0 && self.code != metadata.stringValue {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.codeView!.frame = barCode.bounds
                    self.code = metadata.stringValue!
                    self.type = metadata.type.rawValue
                    
                    var contacts = [Any]()
                    contacts.append([
                        "text": self.code,
                        "format": self.type,
                        "cancelled": "false"
                    ])
                    callFinal.success([
                        "results": contacts
                    ])
                    self.closeScanner()
                }
            }
        }
    }
    
    func failed(call :CAPPluginCall,message:String) {
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
        call.reject(message)
    }
}
