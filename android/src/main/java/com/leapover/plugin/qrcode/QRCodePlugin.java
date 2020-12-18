package com.leapover.plugin.qrcode;



import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.google.zxing.client.android.Intents;
import com.journeyapps.barcodescanner.CaptureActivity;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@NativePlugin(requestCodes = {QRCodePlugin.REQUEST_PERMISSIONS, QRCodePlugin.REQUEST_CODE})
public class QRCodePlugin extends Plugin {
    protected static final int REQUEST_PERMISSIONS = 12345; // Unique request code
    public static final int REQUEST_CODE = 0x0ba7c; // Unique request code
    private final String[] permissions = {Manifest.permission.CAMERA};

    private static final String SCAN = "scan";
    private static final String ENCODE = "encode";
    private static final String CANCELLED = "cancelled";
    private static final String FORMAT = "format";
    private static final String TEXT = "text";
    private static final String DATA = "data";
    private static final String TYPE = "type";
    private static final String PREFER_FRONTCAMERA = "preferFrontCamera";
    private static final String ORIENTATION = "orientation";
    private static final String SHOW_FLIP_CAMERA_BUTTON = "showFlipCameraButton";
    private static final String RESULTDISPLAY_DURATION = "resultDisplayDuration";
    private static final String SHOW_TORCH_BUTTON = "showTorchButton";
    private static final String TORCH_ON = "torchOn";
    private static final String SAVE_HISTORY = "saveHistory";
    private static final String DISABLE_BEEP = "disableSuccessBeep";
    private static final String FORMATS = "formats";
    private static final String PROMPT = "prompt";
    private static final String TEXT_TYPE = "TEXT_TYPE";
    private static final String EMAIL_TYPE = "EMAIL_TYPE";
    private static final String PHONE_TYPE = "PHONE_TYPE";
    private static final String SMS_TYPE = "SMS_TYPE";
    private static final String LOG_TAG = "BarcodeScanner";

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", value);
        call.success(ret);
    }

    @PluginMethod()
    public void scanCode(PluginCall call) {
        saveCall(call);
        pluginRequestPermissions(permissions, REQUEST_PERMISSIONS);
    }

    @Override
    protected void handleRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.handleRequestPermissionsResult(requestCode, permissions, grantResults);
        PluginCall savedCall = getSavedCall();
        if (savedCall == null) {
            Log.d("Test", "No stored plugin call for permissions request result");
            return;
        }
        for (int result : grantResults) {
            if (result == PackageManager.PERMISSION_DENIED) {
                Log.d("Test", "User denied permission");
                return;
            }
        }
        if (requestCode == REQUEST_PERMISSIONS) {
            // We got the permission!
            scanQRCode(savedCall);
        }
    }

    void scanQRCode(PluginCall call) {
        Intent intentScan = new Intent(getContext(), PortraitActivity.class);
        intentScan.putExtra(Intents.Scan.ORIENTATION_LOCKED, false);
        intentScan.setAction(Intents.Scan.ACTION);
        intentScan.addCategory(Intent.CATEGORY_DEFAULT);
        intentScan.setPackage(getContext().getApplicationContext().getPackageName());
        startActivityForResult(call, intentScan, REQUEST_CODE);
    }

    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);
        PluginCall savedCall = getSavedCall();
        if (requestCode == REQUEST_CODE && savedCall != null) {
            ArrayList<Map> scanResult = new ArrayList();
            Map<String, String> map = new HashMap<String, String>();
            if (resultCode == Activity.RESULT_OK) {
                map.put(TEXT, data.getStringExtra("SCAN_RESULT"));
                map.put(FORMAT, data.getStringExtra("SCAN_RESULT_FORMAT"));
                map.put(CANCELLED, "false");
                scanResult.add(map);
                JSONArray jsonArray = new JSONArray(scanResult);
                JSObject ret = new JSObject();
                ret.put("results", jsonArray);
                savedCall.success(ret);
                Log.d(LOG_TAG, TEXT + " : " + data.getStringExtra("SCAN_RESULT"));
                Log.d(LOG_TAG, FORMAT + " : " + data.getStringExtra("SCAN_RESULT_FORMAT"));
            } else if (requestCode == Activity.RESULT_CANCELED) {
                map.put(TEXT, "");
                map.put(FORMAT, "");
                map.put(CANCELLED, "true");
                scanResult.add(map);
                JSONArray jsonArray = new JSONArray(scanResult);
                JSObject ret = new JSObject();
                ret.put("results", jsonArray);
                savedCall.success(ret);
                Log.d(LOG_TAG, CANCELLED);
            } else {
                savedCall.error("Unexpected Error");
            }
        }
    }
}