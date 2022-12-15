
import 'dart:io';
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'base.dart';
// import 'base.dart';

/// EnxPlayerWidget - This widget will automatically manage the native view.
///
/// Enables create native view with `uid` `mode` `local` and destroy native view automatically.
///
class EnxPlayerWidget extends StatefulWidget {
  // uid
  final int uid;
  final int height;
  final int width;

  // local flag
  final bool local;
  final ScalingType mScalingType;
  final bool zMediaOverlay;

  EnxPlayerWidget(
    this.uid, {
    this.local = false,
    this.height = 200,
    this.width = 300,
    this.zMediaOverlay = false,
    this.mScalingType = ScalingType.SCALE_ASPECT_FIT,
    Key? key,
  }) : super(key: key ?? Key(uid.toString()));

  @override
  State<StatefulWidget> createState() => _EnxPlayerWidgetState();
}

class _EnxPlayerWidgetState extends State<EnxPlayerWidget> {
  late Widget _nativeView;

  late int _viewId;

  @override
  void initState() {
    super.initState();
    _nativeView = EnxRtc.createNativeView((viewId) {
      print('enxRtc nativeView: ' + viewId.toString());
      _viewId = viewId;
      _bindView();
    });
  }

  @override
  void dispose() {
    if(Platform.isAndroid) {
      EnxRtc.removeNativeView(_viewId);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EnxPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.uid != oldWidget.uid || widget.local != oldWidget.local)) {
      _bindView();
      return;
    }

    if (widget.mScalingType != oldWidget.mScalingType) {
      setScalingType();
      return;
    }
    if (widget.zMediaOverlay != oldWidget.zMediaOverlay) {
      setScalingType();
      return;
    }
  }

  void _bindView() {
    if (widget.local) {
      EnxRtc.setupVideo(_viewId, 0, widget.local, widget.width, widget.height);
    } else {
      EnxRtc.setupVideo(
          _viewId, widget.uid, widget.local, widget.width, widget.height);
    }
  }

  void setScalingType() {
    if (widget.local) {
      EnxRtc.setPlayerScalingType(
          widget.mScalingType, _viewId, 0, widget.local);
    } else {
      EnxRtc.setPlayerScalingType(
          widget.mScalingType, _viewId, widget.uid, widget.local);
    }
  }

  void setMediaOverlay() {
    if (widget.local) {
      EnxRtc.setZOrderMediaOverlay(_viewId, 0, widget.zMediaOverlay);
    } else {
      EnxRtc.setZOrderMediaOverlay(_viewId, widget.uid, widget.local);
    }
  }

  @override
  Widget build(BuildContext context) => _nativeView;
}
