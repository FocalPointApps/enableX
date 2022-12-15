import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:enx_flutter_plugin/enx_player_widget.dart';
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'package:enx_flutter_plugin/enx_toolbar_widget.dart';


import 'package:fluttertoast/fluttertoast.dart';
class VideoConferenceScreen extends StatefulWidget {
  VideoConferenceScreen({this.token});
  final String token;
  @override
  Conference createState() => Conference();
}

class Conference extends State<VideoConferenceScreen> {
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  bool isAudioEnergy=false;
  String streamId;
  String streamId3;
  int streamId2;
  String base64String;
  bool isScreenShare=false;
  bool isTrans=false;

  @override
  void initState() {
    super.initState();
    print('Enablex Demo');
    initEnxRtc();

      //_initForegroundTask();


    _addEnxrtcEventHandlers();
  }

  Future<void> initEnxRtc() async {
    Map<String, dynamic> map2 = {
      'minWidth': 320,
      'minHeight': 180,
      'maxWidth': 1280,
      'maxHeight': 720
    };
    Map<String, dynamic> map1 = {
      'audio': true,
      'video': true,
      'data': true,
     // 'framerate': 30,
     // 'maxVideoBW': 1500,
     // 'minVideoBW': 150,
      'audioMuted': false,
      'videoMuted': false,
      'name': 'flutter',
     // 'videoSize': map2
    };
    Map<String, dynamic> map3 = {
      'allow_reconnect': true,
      'number_of_attempts': 3,
      'timeout_interval': 15,

    };

    print('tokenRelease:${widget.token}');
    await EnxRtc.joinRoom(widget.token, map1, null, null);
  }

  void _addEnxrtcEventHandlers() {
    EnxRtc.onRoomConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomConnectedFlutter' + jsonEncode(map));
      });
      EnxRtc.publish();

    };

    EnxRtc.onPublishedStream = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onPublishedStream' + jsonEncode(map));
        streamId = map['streamId'];
        EnxRtc.setupVideo(0, 0, true, 300, 200);
      });
    };
    EnxRtc.OnCapturedView=(String bitmap){
      setState(() {
        base64String=bitmap;
        print('OnCapturedView' + bitmap);
        Clipboard.setData(ClipboardData(text: bitmap));



      });
    };
    EnxRtc.onStreamAdded = (Map<dynamic, dynamic> map) {
      print('onStreamAdded' + jsonEncode(map));
      print('onStreamAdded Id' + map['streamId']);

      String streamId1;
      setState(() {
        streamId1 = map['streamId'];
      });
      EnxRtc.subscribe(streamId1);
    };

    EnxRtc.onRoomError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomError' + jsonEncode(map));
      });
    };
    EnxRtc.onNotifyDeviceUpdate = (String deviceName) {
      print('onNotifyDeviceUpdate' + deviceName);
    };

    EnxRtc.onActiveTalkerList = (Map<dynamic, dynamic> map) {
      print('onActiveTalkerList ' + map.toString());

      final items = (map['activeList'] as List)
          .map((i) => new ActiveListModel.fromJson(i));
      if(_remoteUsers.length>0){
        for(int i=0;i<_remoteUsers.length;i++){
          setState(() {
            _remoteUsers.removeAt(i);
          });

        }
      }
      if (items.length > 0) {
        for (final item in items) {
          if(!_remoteUsers.contains(item.streamId)){
            print('_remoteUsers ' + map.toString());
            setState(() {
              streamId2 = item.streamId  ;
              base64String=  item.clientId;
              _remoteUsers.add(item.streamId);
            });
          }
        }
        print('_remoteUsersascashjc');
        print(_remoteUsers);

      }
    };

    EnxRtc.onEventError = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventError' + jsonEncode(map));
      });
    };

    EnxRtc.onEventInfo = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onEventInfo' + jsonEncode(map));
      });
    };
    EnxRtc.onUserConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserConnected' + jsonEncode(map));
      });
    };
    EnxRtc.onUserDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onUserDisConnected' + jsonEncode(map));

      });
    };
    EnxRtc.onRoomDisConnected = (Map<dynamic, dynamic> map) {
      setState(() {
        print('onRoomDisConnected' + jsonEncode(map));
      //  Navigator.pop(context);
        Navigator.pop(context, '/Conference');
      });
    };
    EnxRtc.onAudioEvent = (Map<dynamic, dynamic> map) {
      print('onAudioEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Audio Off") {
          isAudioMuted = true;
        } else {
          isAudioMuted = false;
        }
      });
    };
    EnxRtc.onVideoEvent = (Map<dynamic, dynamic> map) {
      print('onVideoEvent' + jsonEncode(map));
      setState(() {
        if (map['msg'].toString() == "Video Off") {
          isVideoMuted = true;
        } else {
          isVideoMuted = false;
        }
      });
    };
    EnxRtc.onAckSubscribeTalkerNotification=(Map<dynamic, dynamic> map) {
      isAudioEnergy = true;
      print('onAckSubscribeTalkerNotification12' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onAckSubscribeTalkerNotification12+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onAckUnsubscribeTalkerNotification=(Map<dynamic, dynamic> map) {
      print('onAckUnsubscribeTalkerNotification12' + jsonEncode(map));
      isAudioEnergy = false;
      Fluttertoast.showToast(
          msg: "onAckUnsubscribeTalkerNotification12+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onTalkerNtification=(Map<dynamic, dynamic> map) {
      print('onTalkerNtification' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onTalkerNtification+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onClientDiagnosisFailed=(Map<dynamic, dynamic> map) {
      print('onClientDiagnosisFailed' + jsonEncode(map));
    };
    EnxRtc.onClientDiagnosisFinished=(Map<dynamic, dynamic> map) {
      print('onClientDiagnosisFinished' + jsonEncode(map));
    };
    EnxRtc.onClientDiagnosisStatus=(Map<dynamic, dynamic> map) {
      print('onClientDiagnosisStatus' + jsonEncode(map));
    };
    EnxRtc.onClientDiagnosisStopped=(Map<dynamic, dynamic> map) {
      print('onClientDiagnosisStopped' + jsonEncode(map));
    };
    //
    EnxRtc.onAckCreateBreakOutRoom=(Map<dynamic, dynamic> map) {
      print('onAckCreateBreakOutRoom' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onAckCreateBreakOutRoom+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onAckCreateAndInviteBreakOutRoom=(Map<dynamic, dynamic> map) {
      print('onAckCreateAndInviteBreakOutRoom' + jsonEncode(map));
    };
    EnxRtc.onAckInviteBreakOutRoom=(Map<dynamic, dynamic> map) {
      print('onAckInviteBreakOutRoom' + jsonEncode(map));
    };
   /* EnxRtc.onAckPause=(Map<dynamic, dynamic> map) {
      print('onAckPause' + jsonEncode(map));
    };
    EnxRtc.onAckResume=(Map<dynamic, dynamic> map) {
      print('onAckResume' + jsonEncode(map));
    };
    EnxRtc.onAckMuteRoom=(Map<dynamic, dynamic> map) {
      print('onAckMuteRoom' + jsonEncode(map));
    };
    EnxRtc.onAckUnmuteRoom=(Map<dynamic, dynamic> map) {
      print('onAckUnmuteRoom' + jsonEncode(map));
    };*/
    EnxRtc.onFailedJoinBreakOutRoom=(Map<dynamic, dynamic> map) {
      print('onFailedJoinBreakOutRoom' + jsonEncode(map));
    };
    EnxRtc.onConnectedBreakoutRoom=(Map<dynamic, dynamic> map) {
      print('onConnectedBreakoutRoom' + jsonEncode(map));
    };
    EnxRtc.onDisconnectedBreakoutRoom=(Map<dynamic, dynamic> map) {
      print('onDisconnectedBreakoutRoom' + jsonEncode(map));
    };
    EnxRtc.onUserJoinedBreakoutRoom=(Map<dynamic, dynamic> map) {
      print('onUserJoinedBreakoutRoom' + jsonEncode(map));
    };
    EnxRtc.onInvitationForBreakoutRoom=(Map<dynamic, dynamic> map) {
      print('onInvitationForBreakoutRoom' + jsonEncode(map));
    };
    EnxRtc.onDestroyedBreakoutRoom=(Map<dynamic, dynamic> map) {
      print('onDestroyedBreakoutRoom' + jsonEncode(map));
    };
    EnxRtc.onUserDisconnectedFromBreakoutRoom=(Map<dynamic, dynamic> map) {
      print('onUserDisconnectedFromBreakoutRoom' + jsonEncode(map));
    };

    EnxRtc.onUserAwaited=(Map<dynamic, dynamic> map) {
      print('onUserAwaited' + jsonEncode(map));
    };
    EnxRtc.onRoomAwaited=(Map<dynamic, dynamic> map) {
      print('onRoomAwaited' + jsonEncode(map));
    };
    EnxRtc.onAckForApproveAwaitedUser=(Map<dynamic, dynamic> map) {
      print('onAckForApproveAwaitedUser' + jsonEncode(map));
    };
    EnxRtc.onAckForApproveAwaitedUser=(Map<dynamic, dynamic> map) {
      print('onAckForApproveAwaitedUser' + jsonEncode(map));
    };
    EnxRtc.onAckForDenyAwaitedUser=(Map<dynamic, dynamic> map) {
      print('onAckForDenyAwaitedUser' + jsonEncode(map));
    };
    EnxRtc.onAckAddSpotlightUsers=(Map<dynamic, dynamic> map) {
      isAudioEnergy = true;
      print('onAckAddSpotlightUsers' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onAckForDenyAwaitedUser+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onAckRemoveSpotlightUsers=(Map<dynamic, dynamic> map) {
      isAudioEnergy = false;
      print('onAckRemoveSpotlightUsers' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onAckRemoveSpotlightUsers+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onUpdateSpotlightUsers=(Map<dynamic, dynamic> map) {
      print('onUpdateSpotlightUsers' + jsonEncode(map));
    };
    EnxRtc.onAckSwitchedRoom=(Map<dynamic, dynamic> map) {
      print('onAckSwitchedRoom' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onAckSwitchedRoom+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onRoomModeSwitched=(Map<dynamic, dynamic> map) {
      print('onRoomModeSwitched' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onRoomModeSwitched+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    //
    EnxRtc.onHardMutedAudio=(Map<dynamic, dynamic> map){
      isAudioMuted=true;
      Fluttertoast.showToast(
          msg: "onHardMutedVideo+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onHardUnMutedAudio=(Map<dynamic, dynamic> map){
      isAudioMuted=false;
      Fluttertoast.showToast(
          msg: "onHardUnMutedAudio+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onReceivedHardMuteAudio=(Map<dynamic, dynamic> map){
      isAudioMuted=false;
      Fluttertoast.showToast(
          msg: "onHardUnMutedAudio+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onReceivedHardUnMuteAudio=(Map<dynamic, dynamic> map){
      isAudioMuted=false;
      Fluttertoast.showToast(
          msg: "onHardUnMutedAudio+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };

    EnxRtc.onRoomBandwidthAlert=(Map<dynamic,dynamic> map){


    };
    EnxRtc.onAckForDenyAwaitedUser=(Map<dynamic,dynamic> map){

    };
    EnxRtc.onRoomAwaited=(Map<dynamic,dynamic> map){

    };
    EnxRtc.onUserAwaited=(Map<dynamic,dynamic> map){

    };
    EnxRtc.onMessageReceived=(Map<dynamic,dynamic> map){
      Fluttertoast.showToast(
          msg: "onMessageReceived+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };
    EnxRtc.onScreenSharedStarted=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
       msg: "onScreenSharedStarted+${jsonEncode(map)}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    setState(() {
      isScreenShare=true;
      streamId3 = map['streamId'];
    });
  };
  EnxRtc.onScreenSharedStopped=(Map<dynamic, dynamic> map){
    setState(() {
      isScreenShare=false;
   });

    Fluttertoast.showToast(
      msg: "onScreenSharedStopped+${jsonEncode(map)}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
  };
    EnxRtc.onACKStartLiveRecording=(Map<dynamic, dynamic> map){
      print('onACKStartLiveRecording' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onACKStartLiveRecording+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    };
    EnxRtc.onACKStopLiveRecording=(Map<dynamic, dynamic> map){
      print('onACKStopLiveRecording' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onACKStopLiveRecording+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    };
    EnxRtc.onRoomLiveRecordingUpdate=(Map<dynamic, dynamic> map){
      print('onRoomLiveRecordingUpdate' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onRoomLiveRecordingUpdate+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    };
    EnxRtc.onRoomLiveRecordingOn=(Map<dynamic, dynamic> map){
      print('onRoomLiveRecordingOn' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onRoomLiveRecordingOn+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    };
    EnxRtc.onOutBoundCallCancel=(Map<dynamic, dynamic> map){
      print('onOutBoundCallCancel' + jsonEncode(map));
      Fluttertoast.showToast(
          msg: "onOutBoundCallCancel+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    };
    EnxRtc.onAnnotationStarted=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onAnnotationStarted+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
     /* setState(() {
        isScreenShare=true;
        streamId3 = map['streamId'];
      });
*/    };
    EnxRtc.onAnnotationStopped=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onAnnotationStopped+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      /* setState(() {
        isScreenShare=true;
        streamId3 = map['streamId'];
      });
*/    };
    EnxRtc.onStartAnnotationAck=(Map<dynamic, dynamic> map){
    //  isScreenShare=true;
      Fluttertoast.showToast(
          msg: "onStartAnnotationAck+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
       setState(() {
        isScreenShare=true;
        streamId3 = map['streamId'];
      });
   };
    EnxRtc.onStoppedAnnotationAck=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onStoppedAnnotationAck+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
       setState(() {
        isScreenShare=true;
        streamId3 = map['streamId'];
      });
    };
    EnxRtc.onACKStartLiveTranscription=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onACKStartLiveTranscription+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        isTrans=true;
      });
    };
    EnxRtc.onACKStopLiveTranscription=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onACKStopLiveTranscription+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        isTrans=false;
      });
    };
    EnxRtc.onTranscriptionEvents=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onTranscriptionEvents+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
         };

    EnxRtc.onRoomTranscriptionOn=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onRoomTranscriptionOn+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };

    EnxRtc.onSelfTranscriptionOn=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onSelfTranscriptionOn+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };

    EnxRtc.onSelfTranscriptionOff=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onSelfTranscriptionOff+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };

    EnxRtc.onRoomTranscriptionOff=(Map<dynamic, dynamic> map){
      Fluttertoast.showToast(
          msg: "onRoomTranscriptionOff+${jsonEncode(map)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    };


  }

  void _setMediaDevice(String value) {
    Navigator.of(context, rootNavigator: true).pop();
    EnxRtc.switchMediaDevice(value);
  }

  createDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Media Devices'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: deviceList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(deviceList[index].toString()),
                          onTap: () =>
                              _setMediaDevice(deviceList[index].toString()),
                        );
                      },
                    ),
                  )
                ],
              ));
        });
  }

  //
  ReceivePort _receivePort;
/*
  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
        'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    ReceivePort receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',

      );
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is DateTime) {
          print('receive timestamp: $message');
        } else if (message is int) {
          print('receive updateCount: $message');
        }
      });

      return true;
    }

    return false;
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }*/



  void _disconnectRoom() {
    print("fsdf ${streamId2.toString()}");
   EnxRtc.disconnect();
 // EnxRtc.cancelOutboundCall('9871498577');
    //EnxRtc.hardUnMuteVideo(clientId)
    // if(isAudioMuted){
    //   EnxRtc.stopScreenShare();
    //   _stopForegroundTask();
    // }else{
    //   _startForegroundTask();
    //   EnxRtc.startScreenShare();
    //
    // }

   /* else
      EnxRtc.stopScreenShare();*/
  /*  if(isAudioMuted)
   EnxRtc.hardUnMuteVideo(base64String);
    else
      EnxRtc.hardMuteVideo(base64String);*/
   //EnxRtc.onScreenSharedStarted()
  }


  void knockKnock(){

  }

/* void _precallTest() {
   Map<String, dynamic> map = {
     'regionId': 'IN',
     'stop': false,
     'testNames': "MicroPhone"
   };
   EnxRtc.clientDiagnostics(map);
 }*/

  void _spotLight(){
    // if(Platform.isAndroid)
    // _startForegroundTask();

    if(isTrans)
      EnxRtc.stopLiveTranscription();
    else
    EnxRtc.startLiveTranscriptionForRoom("english_us");


    /* var userlist= ['81c168cf-2007-405c-8867-172c59224cda'];


    if (isAudioEnergy) {
      EnxRtc.addSpotlightUsers(userlist);
    } else {
      EnxRtc.removeSpotlightUsers(userlist);
    }*/

    //create breakoutroom
   /* Map<String, dynamic> map = {
      "participants" :2,
      "audio" : true,
      "video": false ,
      "canvas": false,
      "share": false,
      "max_rooms": 1
    };
    EnxRtc.createBreakOutRoom(map);*/

// if(!isAudioEnergy)
//     EnxRtc.switchRoomMode("lecture");
// else
//   EnxRtc.switchRoomMode("group");
//
//     isAudioEnergy=!isAudioEnergy;
  }

  void _toggleAudioEnergy() {

    if (isAudioEnergy) {
      EnxRtc.subscribeForTalkerNotification(false);
    } else {
      EnxRtc.subscribeForTalkerNotification(true);
    }
  }
  void _toggleAudio() {
    if (isAudioMuted) {
      EnxRtc.startLiveRecording({"urlDetails" : {}});
     // EnxRtc.muteSelfAudio(false);
    } else {
      EnxRtc.startLiveRecording({"urlDetails" : {}});
     // EnxRtc.muteSelfAudio(true);
    }
  }

  void _toggleVideo() {
    if (isVideoMuted) {
      EnxRtc.stopLiveRecording();
      //EnxRtc.muteSelfVideo(false);
    } else {
      EnxRtc.stopLiveRecording();
      //EnxRtc.muteSelfVideo(true);
    }
  }


  void _toggleSpeaker() async {
    List<dynamic> list = await EnxRtc.getDevices();
    setState(() {
      deviceList = list;
    });
    print('deviceList');
    print(deviceList);
    createDialog();
  }

  void _toggleCamera() {
    EnxRtc.sendMessage(
        "🤑", true, []);
   // EnxRtc.switchCamera();
  }

  int remoteView = -1;
  List<dynamic> deviceList;

  Widget _viewRows() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        for (final widget in _renderWidget)
          Container(
            height: 120,
            width: 120,
            child: widget,

          ),

      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    for (final streamId in _remoteUsers) {
      // double width = MediaQuery.of(context).size.width;
      yield EnxPlayerWidget(streamId, local: false,width:40,height:40);

    }
  }

  final _remoteUsers = List<int>();


  @override
  Widget build(BuildContext context) {
    int playerWidth = MediaQuery.of(context).size.width.toInt();
    int playerHeight = MediaQuery.of(context).size.height.toInt();
    print(playerWidth);
    const String viewType = 'EnxToolbarView';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};


    return  Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text('Flutter'),
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              Stack(
                children: <Widget>[
               /*   isScreenShare?  Container(
                  height: MediaQuery.of(context).size.height/1.17,
                  width: MediaQuery.of(context).size.width,
                  child: EnxPlayerWidget(int.parse(streamId3), local: false,width: playerWidth, height: playerHeight),
                       ):Visibility( visible:false,child: Container()),
               */
                  isScreenShare?
                  Container(
                    height: MediaQuery.of(context).size.height/1.17,
                    width: MediaQuery.of(context).size.width,
                    child: EnxPlayerWidget(streamId2.toInt(), local: false,width: playerWidth, height: playerHeight),
                  ):
                  Visibility(
                        visible: true,
                        child: Container(
                        height: MediaQuery.of(context).size.height/1.5,
                        width: MediaQuery.of(context).size.width,
                      child: EnxPlayerWidget(0, local: true,width: playerWidth, height: playerHeight),
                  ),
              ),
               /*   isScreenShare? Positioned(
                      bottom: 250,
                      left: 20,
                      right: 20,

                      child: EnxToolbarWidget(width:100 ,height:50 )
                  ):Container(),
*/


                ],
              ),    _remoteUsers?.length > 0 ? Positioned(
                  bottom: 95,
                  left: 20,
                  right: 20,
                  child:Card(
                    color: Colors.transparent,
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        height:90,
                        width: MediaQuery.of(context).size.width,
                        child: _viewRows()
                    ),
                  )) : Container(),

              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  color: Colors.white,
                  // height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 7,
                        child: MaterialButton(
                          child: isAudioMuted
                              ? Image.asset(
                            'assets/mute_audio.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          )
                              : Image.asset(
                            'assets/unmute_audio.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                          onPressed: _toggleAudio,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 7,
                        child: MaterialButton(
                          child: Image.asset(
                            'assets/camera_switch.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                          onPressed: _toggleCamera,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 7,
                        child: MaterialButton(
                          child: isVideoMuted
                              ? Image.asset(
                            'assets/mute_video.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          )
                              : Image.asset(
                            'assets/unmute_video.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                          onPressed: _toggleVideo,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 8,
                        child: MaterialButton(
                          child: Image.asset(
                            'assets/unmute_speaker.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                          onPressed: _toggleSpeaker,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 8,
                        child: MaterialButton(
                          child: Image.asset(
                            'assets/disconnect.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                          onPressed: _disconnectRoom,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 8,
                        child: MaterialButton(
                          child: Image.asset(
                            'assets/unmute_speaker.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                          onPressed: _spotLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class ActiveList {
  bool active;
  List<ActiveListModel> activeList = [];
  String event;

  ActiveList(this.active, this.activeList, this.event);

  factory ActiveList.fromJson(Map<dynamic, dynamic> json) {
    return ActiveList(
      json['active'] as bool,
      (json['activeList'] as List).map((i) {
        return ActiveListModel.fromJson(i);
      }).toList(),
      json['event'] as String,
    );
  }
}

class ActiveListModel {
  String name;
  int streamId;
  String clientId;
  String videoaspectratio;
  String mediatype;
  bool videomuted;
  String reason;

  ActiveListModel(this.name, this.streamId, this.clientId,
      this.videoaspectratio, this.mediatype, this.videomuted, this.reason);

  // convert Json to an exercise object
  factory ActiveListModel.fromJson(Map<dynamic, dynamic> json) {
    int sId = int.parse(json['streamId'].toString());
    return ActiveListModel(
      json['name'] as String,
      sId,
//      json['streamId'] as int,
      json['clientId'] as String,
      json['videoaspectratio'] as String,
      json['mediatype'] as String,
      json['videomuted'] as bool,
      json['reason'] as String,
    );
  }
}