package com.enx_plugin.enx_flutter_plugin;

import android.content.Context;
import android.view.View;
// import android.view.ViewGroup;
import android.widget.FrameLayout;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import enx_rtc_android.annotations.EnxAnnotationsToolbar;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;


class EnxToolbarViewFactory extends PlatformViewFactory {
    EnxToolbarView platformView;
    private final EnxFlutterPlugin mFlutterPlugin;

    // @NonNull private final BinaryMessenger messenger;
    // @NonNull private final View containerView;

    // NativeViewFactory(@NonNull BinaryMessenger messenger, @NonNull View containerView) {
    //   super(StandardMessageCodec.INSTANCE);
    //   this.messenger = messenger;
    //   this.containerView = containerView;
    // }
    EnxToolbarViewFactory(MessageCodec<Object> createArgsCodec, EnxFlutterPlugin enxFlutterPlugin) {
        super(createArgsCodec);
        this.mFlutterPlugin = enxFlutterPlugin;
    }


    @NonNull
    @Override
    public EnxToolbarView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        platformView = new EnxToolbarView(context, id, creationParams);
        System.out.println("toolbarcreate renderID "+id);

        return platformView;
    }

    public EnxAnnotationsToolbar getView() {
        return platformView.getView();
    }
}