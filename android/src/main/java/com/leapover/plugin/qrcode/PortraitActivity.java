package com.leapover.plugin.qrcode;

import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.journeyapps.barcodescanner.CaptureActivity;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;
import com.journeyapps.barcodescanner.ViewfinderView;
import com.leapover.plugin.qrcode.qrcodeplugin.R;

public class PortraitActivity extends CaptureActivity implements DecoratedBarcodeView.TorchListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ViewfinderView viewfinderView = findViewById(R.id.zxing_viewfinder_view);
        viewfinderView.setLaserVisibility(false);
        viewfinderView.setPossiblePointsVisibility(false);
        viewfinderView.showInnerSquare(40, 40, 4, Color.WHITE);
        TextView statusView = findViewById(R.id.zxing_status_view);
        statusView.setVisibility(View.GONE);
    }

    @Override
    public void onTorchOn() {

    }

    @Override
    public void onTorchOff() {

    }
}
