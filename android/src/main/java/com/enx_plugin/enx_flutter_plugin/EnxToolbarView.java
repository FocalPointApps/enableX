package com.enx_plugin.enx_flutter_plugin;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import enx_rtc_android.annotations.EnxAnnotationsToolbar;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;


class EnxToolbarView implements PlatformView {
    // @NonNull private final TextView textView;
    @NonNull private  EnxAnnotationsToolbar view = null;

    EnxToolbarView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        try {
            view = new EnxAnnotationsToolbar(context);
            LinearLayout.LayoutParams viewletParams = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                 viewletParams.gravity= Gravity.BOTTOM;
            view.setLayoutParams(viewletParams);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @NonNull
    @Override
    public EnxAnnotationsToolbar getView() {
        return view;
    }

    @Override
    public void dispose() {}
}
