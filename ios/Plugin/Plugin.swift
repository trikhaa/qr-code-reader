import Foundation
import Capacitor
import AVFoundation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(QRCodePlugin)
public class QRCodePlugin: CAPPlugin, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.success([
            "value": value
        ])
    }

    @objc func scanCode(_ call: CAPPluginCall) {

        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed(call:call,message:"No Camera found") 
            return 
        }
        let videoInput: AVCaptureDeviceInput
         do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed(call:call,message:"Failed to init camera")
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed(call:call,message:"Unable to add input")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed(call:call,message:"Unable to add output")
            return
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()



        // let contactStore = CNContactStore()
        // var contacts = [Any]()
        // let keys = [
        //         CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        //                 CNContactPhoneNumbersKey,
        //                 CNContactEmailAddressesKey
        //         ] as [Any]
        // let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        // contactStore.requestAccess(for: .contacts) { (granted, error) in
        //     if let error = error {
        //         print("failed to request access", error)
        //         call.reject("access denied")
        //         return
        //     }
        //     if granted {
        //        do {
        //            try contactStore.enumerateContacts(with: request){
        //                    (contact, stop) in
        //             contacts.append([
        //                 "firstName": contact.givenName,
        //                 "lastName": contact.familyName,
        //                 "telephone": contact.phoneNumbers.first?.value.stringValue ?? ""
        //             ])
        //            }
        //            print(contacts)
        //            call.success([
        //                "results": contacts
        //            ])
        //        } catch {
        //            print("unable to fetch contacts")
        //            call.reject("Unable to fetch contacts")
        //        }
        //     } else {
        //         print("access denied")
        //         call.reject("access denied")
        //     }
        // }
    }

    func failed(call :CAPPluginCall,message:String) {
        call.reject(message)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { 
                failed(call:call,message:"Unable to read output")
                return }
            guard let stringType = readableObject.type else { 
                failed(call:call,message:"Unable to read output")
                return
             }
            guard let stringValue = readableObject.stringValue else { 
                failed(call:call,message:"Unable to read output")
                return
             }

            var contacts = [Any]()
            contacts.append([
                "text": stringValue,
                "format": stringType,
                "cancelled": "false"
            ])
            call.success([
                "results": contacts
            ])
        }

        dismiss(animated: true)
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
