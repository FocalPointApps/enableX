package com.enx_plugin.enx_flutter_plugin;

import android.content.Context;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class EnxPlayerViewFactory extends PlatformViewFactory {
    private final EnxFlutterPlugin mFlutterPlugin;

    public EnxPlayerViewFactory(MessageCodec<Object> createArgsCodec, EnxFlutterPlugin enxFlutterPlugin) {
        super(createArgsCodec);
        this.mFlutterPlugin = enxFlutterPlugin;
    }

    /**
     * create method called while creating a new native view
     */
    @Override
    public PlatformView create(Context context, int id, Object o) {
        FrameLayout view = new FrameLayout(mFlutterPlugin.mActivity);
        view.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        EnxPlayer rendererView = new EnxPlayer(view, id);
        mFlutterPlugin.addView(view, id);
        System.out.println("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvoncreate renderID "+id);
        return rendererView;
    }
}