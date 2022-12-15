
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enx_flutter_plugin.dart';

class EnxToolbarWidget extends StatefulWidget {
 final int width;
 final int height;
  EnxToolbarWidget({required this.width,required this.height});
  @override
  State<StatefulWidget> createState() => _EnxToolbarWidgetState ();
}

class _EnxToolbarWidgetState  extends State<EnxToolbarWidget>{
  late Widget _nativeView;
  @override
  void initState() {
    super.initState();
    _bindView();

  }

  @override
  void dispose(){
    /*if(Platform.isAndroid) {
      EnxRtc.removeNativeView(_viewId);
    }
*/    super.dispose();

  }

  @override
  void didUpdateWidget(EnxToolbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

   //_bindView();
      return;



  }


  void _bindView() {
    EnxRtc.setupToolbar(widget.width,widget.height);

  }

  @override
  Widget build(BuildContext context){
    final Map<String, dynamic> creationParams = <String, dynamic>{'width':widget.width,'height':widget.height};
    return SizedBox(height: 100,child: Platform.isIOS ? UiKitView(
        viewType: 'EnxToolbarView',
       layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
    )
     : AndroidView(
    viewType: 'EnxToolbarView',
    layoutDirection: TextDirection.ltr,
    creationParams: creationParams,
    creationParamsCodec: const StandardMessageCodec(),

    )
    );
  }


}
