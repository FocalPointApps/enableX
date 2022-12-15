package com.enx_plugin.enx_flutter_plugin;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;

import io.flutter.plugin.platform.PlatformView;

public class EnxPlayer implements PlatformView {
    private final FrameLayout mEnxPlayerView;
    private final long uid;


    public EnxPlayer(FrameLayout enxPlayerView, int id) {
        this.uid = id;
        mEnxPlayerView = enxPlayerView;
    }

    @Override
    public View getView() {
        return mEnxPlayerView;
    }

    @Override
    public void dispose() {
    }
}