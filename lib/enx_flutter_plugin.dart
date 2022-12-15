import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base.dart';

class EnxRtc {
  static const MethodChannel _channel =
      const MethodChannel('enx_flutter_plugin');
  static const EventChannel _eventChannel =
      const EventChannel('enx_flutter_plugin_event_channel');

  static void Function(dynamic err)? onError;

/* Event called on success of room connection. */
  static void Function(Map<dynamic, dynamic> map)? onRoomConnected;

  /* Event called on error while room connection. */
  static void Function(Map<dynamic, dynamic> map)? onRoomError;

  /* Event called when room is disconected successfully. */
  static void Function(Map<dynamic, dynamic> map)? onRoomDisConnected;

  /* Event called on stream published successfully. */
  static void Function(Map<dynamic, dynamic> map)? onPublishedStream;

  /* Event called on stream subscribed successfully. */
  static void Function(Map<dynamic, dynamic> map)? onSubscribedStream;

  /* Event called on stream has been published. */
  static void Function(Map<dynamic, dynamic> map)? onStreamAdded;

  /* Event when a user is connected to a room, all other connected users are notified about the new user. */
  static void Function(Map<dynamic, dynamic> map)? onUserConnected;

  /* Event called when a user is disconnected from a room, all other connected users are notified about the users exit. */
  static void Function(Map<dynamic, dynamic> map)? onUserDisConnected;

  /* Event called to receive custom signaling event message at room Level. */
  static void Function(Map<dynamic, dynamic> map)? onUserDataReceived;

  /* Event called to receive message at room Level. */
  static void Function(Map<dynamic, dynamic> map)? onMessageReceived;

  /* Event called on acknowledge send Data. */
  static void Function(Map<dynamic, dynamic> map)? onAcknowledgedSendData;

  /* Event called on receiving information for any event. */
  static void Function(Map<dynamic, dynamic> map)? onEventInfo;

  /* Event called on any event error. */
  static void Function(Map<dynamic, dynamic> map)? onEventError;

  /* Event called to get updated active talker list. */
  static void Function(Map<dynamic, dynamic> map)? onActiveTalkerList;

  /* Event called on acknowledge switch user role. */
  static void Function(Map<dynamic, dynamic> map)? onSwitchedUserRole;

  /* Event called on acknowledge when user role changed */
  static void Function(Map<dynamic, dynamic> map)? onUserRoleChanged;

  /* Event on acknowledge destroy room for moderator */
  static void Function(Map<dynamic, dynamic> map)? onAckDestroy;

  /* Event on acknowledge drop user for moderator */
  static void Function(Map<dynamic, dynamic> map)? onAckDropUser;

  /* Event received for remaining conference duration */
  static void Function(Map<dynamic, dynamic> map)?
      onConferenceRemainingDuration;

  /* Event received when conference extended */
  static void Function(Map<dynamic, dynamic> map)? onConferencessExtended;

  /* Event when the recording is turned off (either implicitly or explicitly), all connected users are notified that recording has been stopped in the room. */
  static void Function(Map<dynamic, dynamic> map)? onRoomRecordingOff;

  /* Event called when recording stopped by the moderator. */
  static void Function(Map<dynamic, dynamic> map)? onStopRecordingEvent;

  /* Event when recording is started in the room, (either implicitly or explicitly), all connected users are notified that room is being recorded.. */
  static void Function(Map<dynamic, dynamic> map)? onRoomRecordingOn;

  /* Event called when recording started by the moderator. */
  static void Function(Map<dynamic, dynamic> map)? onStartRecordingEvent;

  /* Event called when the user set number of active talker. */
  static void Function(Map<dynamic, dynamic> map)? onSetTalkerCount;

  /* Event called when the user request to get opted active talker streams set by them. */
  static void Function(Map<dynamic, dynamic> map)? onGetTalkerCount;

  /* Event to get the maximum number of allowed Active Talkers in the connected room. */
  static void Function(Map<dynamic, dynamic> map)? onMaxTalkerCount;

  /* Event called when the log is uploaded successfully to the server. */
  static void Function(Map<dynamic, dynamic> map)? onLogUploaded;

  /* Event will notify if a significant change in bandwidth for remote streams. */
  static void Function(Map<dynamic, dynamic> map)? onBandWidthUpdated;

  /* Event will notify if a significant change in share streams. */
  static void Function(Map<dynamic, dynamic> map)? onShareStreamEvent;

  /* Event will notify if a significant change in canvas streams. */
  static void Function(Map<dynamic, dynamic> map)? onCanvasStreamEvent;

  /* Event will notify if there is an interruption in connection. */
  static void Function(Map<dynamic, dynamic> map)? onConnectionInterrupted;

  /* Event will notify if the connection has lost. */
  static void Function(Map<dynamic, dynamic> map)? onConnectionLost;

  /* Event for participant on the success of requestFloor. This is for participant only. */
  static void Function(Map<dynamic, dynamic> map)? onFloorRequested;

  /* Event for Moderatoron any Floor Request raised by the participant. This is for Moderator only. */
  static void Function(Map<dynamic, dynamic> map)? onFloorRequestReceived;

  /* Event for Moderator on performing actions like grantFloor, denyFloor, releaseFloor. */
  static void Function(Map<dynamic, dynamic> map)? onProcessFloorRequested;

/* Event for Participant when the moderator performs action grantFloor. */
  static void Function(Map<dynamic, dynamic> map)? onGrantedFloorRequest;

  /* Event for Participant when the moderator performs action denyFloor. */
  static void Function(Map<dynamic, dynamic> map)? onDeniedFloorRequest;

  /* Event for Participant when the moderator performs action releaseFloor. */
  static void Function(Map<dynamic, dynamic> map)? onReleasedFloorRequest;

  /* Event for Participant when the moderator hard unmute the room. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedHardUnMute;

  /* Event when moderator hard unmute the room. */
  static void Function(Map<dynamic, dynamic> map)? onHardUnMuted;

  /* Event for Participant when the moderator hard mute the room. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedHardMute;

  /* Event when moderator hard mute the room. */
  static void Function(Map<dynamic, dynamic> map)? onHardMuted;

  /* Event received for self audio mute/unmute */
  static void Function(Map<dynamic, dynamic> map)? onAudioEvent;

  /* Event received for self video mute/unmute */
  static void Function(Map<dynamic, dynamic> map)? onVideoEvent;

/* Event called when receive data on the streams. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedData;

  /* Event called when a self mute audio alert participant received from server. */
  static void Function(Map<dynamic, dynamic> map)? onRemoteStreamAudioMute;

  /* Event called when a self unmute audio alert participant received from server. */
  static void Function(Map<dynamic, dynamic> map)? onRemoteStreamAudioUnMute;

  /* Event called when a self mute video alert participant received from server. */
  static void Function(Map<dynamic, dynamic> map)? onRemoteStreamVideoMute;

  /* Event called when a self unmute video alert participant received from server. */
  static void Function(Map<dynamic, dynamic> map)? onRemoteStreamVideoUnMute;

  /* Event called there is any update for advanced options. */
  static void Function(Map<dynamic, dynamic> map)? onAdvancedOptionsUpdate;

  /* Event received to get all the advantioned options. */
  static void Function(Map<dynamic, dynamic> map)? onGetAdvancedOptions;

  /* Event on acknowledge room locked for moderator. */
  static void Function(Map<dynamic, dynamic> map)? onAckLockRoom;

  /* Event on acknowledge room unlocked for moderator. */
  static void Function(Map<dynamic, dynamic> map)? onAckUnLockRoom;

  /* Event called when room is locked. */
  static void Function(Map<dynamic, dynamic> map)? onLockedRoom;

  /* Event when room is unlocked. */
  static void Function(Map<dynamic, dynamic> map)? onUnLockedRoom;

  /* Event when outbound call initiated */
  static void Function(Map<dynamic, dynamic> map)? onOutBoundCallInitiated;

  /* Event called to getthe dial state event. */
  static void Function(String state)? onDialStateEvents;
  static void Function(String state)? onDTMFCollected;
  static void Function(Map<dynamic, dynamic> map)? onDialStateEvent;
  static void Function(Map<dynamic, dynamic> map)? onDTMFCollecteds;
  static void Function(Map<dynamic, dynamic> map)? onOutBoundCallCancel;


/* Event called on Success of single user mute by moderator. This delegate method is for moderator. */
  static void Function(Map<dynamic, dynamic> map)? onHardMutedAudio;

  /* Event called on Success of single user unmute by moderator. This delegate method is for moderator. */
  static void Function(Map<dynamic, dynamic> map)? onHardUnMutedAudio;

  /* Event called on Success of single user mute by moderator. This delegate method is for participant. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedHardMuteAudio;

  /* Event called on Success of single user unmute by moderator. This delegate method is for participant. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedHardUnMuteAudio;

/* Event called when a hard mute video alert moderator received from server. This delegate is for moderator. */
  static void Function(Map<dynamic, dynamic> map)? onHardMutedVideo;

  /* Event called when a hard unmute video alert moderator received from server. This delegate is for moderator. */
  static void Function(Map<dynamic, dynamic> map)? onHardUnMutedVideo;

  /* Event called when a hard mute video alert participant received from server. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedHardMuteVideo;

  /* Event called when a hard unmute video alert participant received from server. */
  static void Function(Map<dynamic, dynamic> map)? onReceivedHardUnMuteVideo;

  /* Event will called when reconnect triggerred. */
  static void Function(String message)? onReconnect;

  /* Event called when a media device changed. */
  static void Function(String deviceName)? onNotifyDeviceUpdate;

  /* Event will called on reconnect success. */
  static void Function(Map<dynamic, dynamic> map)? onUserReconnectSuccess;

  /* Event called when screen share started. */
  static void Function(Map<dynamic, dynamic> map)? onScreenSharedStarted;

  /* Event called when screen share stopped. */
  static void Function(Map<dynamic, dynamic> map)? onScreenSharedStopped;

  /* Event called when screen share started. */
  static void Function(Map<dynamic, dynamic> map)? onStartScreenShareACK;

  /* Event called when screen share stopped. */
  static void Function(Map<dynamic, dynamic> map)? onStoppedScreenShareACK;

  /*Event call when screen share exit from iOS*/
  static void Function(Map<dynamic, dynamic> map)? onExitScreenShareACK;

/* Event called when screen canvas stopped. */
  static void Function(Map<dynamic, dynamic> map)? onCanvasStarted;

  /* Event called when screen canvas stopped. */
  static void Function(Map<dynamic, dynamic> map)? onCanvasStopped;

/* Event called when file upload start. */
  static void Function(Map<dynamic, dynamic> map)? onFileUploadStarted;

  /* Event called when file available to download. */
  static void Function(Map<dynamic, dynamic> map)? onFileAvailable;

  /* Event called when someone started file upload. */
  static void Function(Map<dynamic, dynamic> map)? onInitFileUpload;

  /* Event called when file uploaded successfully. */
  static void Function(Map<dynamic, dynamic> map)? onFileUploaded;

  /* Event called when file upload cancelled . */
  static void Function(Map<dynamic, dynamic> map)? onFileUploadCancelled;

  /* Event called when file upload failed.*/
  static void Function(Map<dynamic, dynamic> map)? onFileUploadFailed;

  /* Event called when file downloaded successfully.*/
  static void Function(Map<dynamic, dynamic> map)? onFileDownloaded;

  /* Event called when file download cancelled . */
  static void Function(Map<dynamic, dynamic> map)? onFileDownloadCancelled;

  /* Event called when file download failed.*/
  static void Function(Map<dynamic, dynamic> map)? onFileDownloadFailed;

  /* Event called when file download started.*/
  static void Function(Map<dynamic, dynamic> map)? onInitFileDownload;

  /* Event called when stats event registered successfully.*/
  static void Function(Map<dynamic, dynamic> map)? onAcknowledgeStats;

  /* Event called when stats received.*/
  static void Function(Map<dynamic, dynamic> map)? onReceivedStats;

  /* Event called when screenshot captured. */
  static void Function(String bitmap)? OnCapturedView;

  /* This delegate method will notify to all available modiatore, Once any participent has canceled there floor request */
  static void Function(Map<dynamic, dynamic> map)? onCancelledFloorRequest;

  /* This ACK method for Participent , When he/she will cancle their request floor*/
  static void Function(Map<dynamic, dynamic> map)? onFloorCancelled;

  /* This delegate method will notify to all available modiatore, Once any participent has finished there floor request
    */
  static void Function(Map<dynamic, dynamic> map)? onFinishedFloorRequest;

  /* This ACK method for Participent , When he/she will finished their request floor
    after request floor accepted by any modiatore*/
  static void Function(Map<dynamic, dynamic> map)? onFloorFinished;

  static void Function(Map<dynamic, dynamic> map)? onACKInviteToFloorRequested;
  static void Function(Map<dynamic, dynamic> map)? onInviteToFloorRequested;
  static void Function(Map<dynamic, dynamic> map)? onInvitedForFloorAccess;
  static void Function(Map<dynamic, dynamic> map)? onCanceledFloorInvite;
  static void Function(Map<dynamic, dynamic> map)? onRejectedInviteFloor;
  static void Function(Map<dynamic, dynamic> map)? onAcceptedFloorInvite;



  /* This ACK method for Participent , */
  static void Function(Map<dynamic, dynamic> map)? onAckPinUsers;

  static void Function(Map<dynamic, dynamic> map)? onAckUnpinUsers;

  static void Function(Map<dynamic, dynamic> map)? onPinnedUsers;


  static void Function(Map<dynamic, dynamic> map)? onRoomAwaited;
  static void Function(Map<dynamic, dynamic> map)? onUserAwaited;
  static void Function(Map<dynamic, dynamic> map)? onAckForApproveAwaitedUser;
  static void Function(Map<dynamic, dynamic> map)? onAckForDenyAwaitedUser;
  static void Function(Map<dynamic, dynamic> map)? onRoomBandwidthAlert;
  static void Function(Map<dynamic, dynamic> map)? onStopAllSharingACK;


  /* Event called when screen share started. */
  static void Function(Map<dynamic, dynamic> map)? onAnnotationStarted;

  /* Event called when screen share stopped. */
  static void Function(Map<dynamic, dynamic> map)? onAnnotationStopped;

  /* Event called when screen share started. */
  static void Function(Map<dynamic, dynamic> map)? onStartAnnotationAck;

  /* Event called when screen share stopped. */
  static void Function(Map<dynamic, dynamic> map)? onStoppedAnnotationAck;


  //Subscribe talker notification
  static void Function(Map<dynamic, dynamic> map)?
      onAckSubscribeTalkerNotification;

  //UnSubscribe talker notification
  static void Function(Map<dynamic, dynamic> map)?
      onAckUnsubscribeTalkerNotification;
  //Receive talker notification
  static void Function(Map<dynamic, dynamic> map)? onTalkerNtification;

  //Precall test trubleshooter failed
  static void Function(Map<dynamic, dynamic> map)? onClientDiagnosisFailed;
  //Precall test trubleshooter stop
  static void Function(Map<dynamic, dynamic> map)? onClientDiagnosisStopped;
  //Precall test trubleshooter finished
  static void Function(Map<dynamic, dynamic> map)? onClientDiagnosisFinished;
  //Precall test trubleshooter status
  static void Function(Map<dynamic, dynamic> map)? onClientDiagnosisStatus;

  //Acknowledgement for create breakout room
  static void Function(Map<dynamic, dynamic> map)? onAckCreateBreakOutRoom;
  //Acknowledgement for create and invite breakout room
  static void Function(Map<dynamic, dynamic> map)?
      onAckCreateAndInviteBreakOutRoom;
  //Acknowledgement for Invite participants into breakout room
  static void Function(Map<dynamic, dynamic> map)? onAckInviteBreakOutRoom;

  // //Acknowledgement for pause parent room after get in into breakout room
  // static void Function(Map<dynamic, dynamic> map)? onAckPause;
  // //Acknowledgement for resume parent room after get out from breakout room
  // static void Function(Map<dynamic, dynamic> map)? onAckResume;
  //
  // //Acknowledgement for mute parent room after get in into breakout room
  // static void Function(Map<dynamic, dynamic> map)? onAckMuteRoom;
  // //Acknowledgement for unmute parent room after get out  breakout room
  // static void Function(Map<dynamic, dynamic> map)? onAckUnmuteRoom;

  //Event  for fail to join breakout room
  static void Function(Map<dynamic, dynamic> map)? onFailedJoinBreakOutRoom;
  //Event  for connected to  breakout room
  static void Function(Map<dynamic, dynamic> map)? onConnectedBreakoutRoom;
  //Event  for disconnect to  breakout room
  static void Function(Map<dynamic, dynamic> map)? onDisconnectedBreakoutRoom;
  //Event  for user  join to breakout room
  static void Function(Map<dynamic, dynamic> map)? onUserJoinedBreakoutRoom;
  //Event  for Invitation to breakout room
  static void Function(Map<dynamic, dynamic> map)? onInvitationForBreakoutRoom;
  //Event  for destroy to  breakout room
  static void Function(Map<dynamic, dynamic> map)? onDestroyedBreakoutRoom;
  //Event  for User disconnect  to  breakout room
  static void Function(Map<dynamic, dynamic> map)?
      onUserDisconnectedFromBreakoutRoom;

  static void Function(Map<dynamic, dynamic> map)? onAckRejectBreakOutRoom;
  static void Function(Map<dynamic, dynamic> map)? onBreakoutRoomCreated;
  static void Function(Map<dynamic, dynamic> map)? onBreakoutRoomInvited;
  static void Function(Map<dynamic, dynamic> map)? onBreakoutRoomInviteRejected;
  //Spot light
  /* This ACK method for Participent , */
  static void Function(Map<dynamic, dynamic> map)? onAckAddSpotlightUsers;

  static void Function(Map<dynamic, dynamic> map)? onAckRemoveSpotlightUsers;

  static void Function(Map<dynamic, dynamic> map)? onUpdateSpotlightUsers;

  static void Function(Map<dynamic, dynamic> map)? onAckSwitchedRoom;
  static void Function(Map<dynamic, dynamic> map)? onRoomModeSwitched;

  static void Function(Map<dynamic, dynamic> map)? onAckStartStreaming;
  static void Function(Map<dynamic, dynamic> map)? onAckStopStreaming;
  static void Function(Map<dynamic, dynamic> map)? onStreamingStarted;
  static void Function(Map<dynamic, dynamic> map)? onStreamingStopped;
  static void Function(Map<dynamic, dynamic> map)? onStreamingFailed;
  static void Function(Map<dynamic, dynamic> map)? onStreamingUpdated;




/*Live Recording */
  static void Function(Map<dynamic, dynamic> map)? onACKStartLiveRecording;
  static void Function(Map<dynamic, dynamic> map)? onACKStopLiveRecording;
  static void Function(Map<dynamic, dynamic> map)? onRoomLiveRecordingOn;
  static void Function(Map<dynamic, dynamic> map)? onRoomLiveRecordingOff;
  static void Function(Map<dynamic, dynamic> map)? onRoomLiveRecordingFailed;
  static void Function(Map<dynamic, dynamic> map)? onRoomLiveRecordingUpdate;





  /*   */
  static void Function(Map<dynamic, dynamic> map)? onAckHardMuteUserAudio;
  static void Function(Map<dynamic, dynamic> map)? onAckHardunMuteUserAudio;
  static void Function(Map<dynamic, dynamic> map)? onAckHardMuteUserVideo;
  static void Function(Map<dynamic, dynamic> map)? onAckHardUnMuteUserVideo;

/*LiveTranscription*/
  static void Function(Map<dynamic, dynamic> map)? onACKStartLiveTranscription;
  static void Function(Map<dynamic, dynamic> map)? onACKStopLiveTranscription;
  static void Function(Map<dynamic, dynamic> map)? onTranscriptionEvents;
  static void Function(Map<dynamic, dynamic> map)? onRoomTranscriptionOn;
  static void Function(Map<dynamic, dynamic> map)? onRoomTranscriptionOff;
  static void Function(Map<dynamic, dynamic> map)? onSelfTranscriptionOn;
  static void Function(Map<dynamic, dynamic> map)? onSelfTranscriptionOff;

/*HLS Streaming*/
  static void Function(Map<dynamic, dynamic> map)? onHlsStarted;
  static void Function(Map<dynamic, dynamic> map)? onHlsStopped;
  static void Function(Map<dynamic, dynamic> map)? onHlsFailed;
  static void Function(Map<dynamic, dynamic> map)? onHlsWaiting;

  static StreamSubscription<dynamic>? _sink;

  static void _addEventChannelHandler() async {
    print('facebook:1234');
    _sink = _eventChannel.receiveBroadcastStream().listen(_eventListener);
    _sink = _eventChannel
        .receiveBroadcastStream()
        .listen(_eventListener, onError: onError);
  }

/*
 To quick start and join the room.
 @param String token it is encoded token string received from Enx application server.
 @param Map<String> localInfo for local streams
 @param Map<String> roomInfo
 @param List<dynamic> advanceOptions


 @return void
 */
  static Future<void> joinRoom(String token, Map<String, dynamic> localInfo,
      Map<String, dynamic> roomInfo, List<dynamic> advanceOptions) async {
    if(token =="null" || token.isEmpty){
      return ;
    }

    await _channel.invokeMethod('joinRoom', {
      'token': token,
      'localInfo': localInfo,
      'roomInfo': roomInfo,
      'advanceOptions': advanceOptions
    });
    _addEventChannelHandler();
  }

  /*static Future<void> EnxRtc() async {
    await _channel.invokeMethod('EnxRtc');
    _addEventChannelHandler();
  }*/

  /*
  To publish the local stream in connected room.
  @return void
  */
  static Future<void> publish() async {
    await _channel.invokeMethod('publish');
  }

  /*
  To subscribe the remote stream in connected room.
  @return String
  */

  static Future<void> subscribe(String streamId) async {
    print(streamId);
    await _channel.invokeMethod('subscribe', {
      "streamId": streamId,
    });
  }

  /*
  To change camera
  */

  static Future<void> switchCamera() async {
    await _channel.invokeMethod('switchCamera', {});
  }

  /*
  To disconnect the connected room.
  @return void
  */
  static Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  /*
  To start recording in the connected room.
  @return void
  */
  static Future<void> startRecord() async {
    await _channel.invokeMethod('startRecord');
  }

  /*
  To stop recording in the connected room.
  @return void
  */
  static Future<void> stopRecord() async {
    await _channel.invokeMethod('stopRecord');
  }

  /*
  The setTalkerCount method is used to opt total number of streams to receive at a Client End point in Active Talkers.

  @param int count to set total number of streams opted to receive in Active Talker.
  @return void
  */
  static Future<void> setTalkerCount(int count) async {
    await _channel.invokeMethod('setTalkerCount', {'count': count});
  }

  /*
   To get of number of talker count .
   @return void
  */
  static Future<void> getTalkerCount() async {
    await _channel.invokeMethod('getTalkerCount');
  }

  /*
  This method is available for all users during Active Talker Mode. Using this method, you can get maximum number of allowed Active Talkers in the room.
  @return void
  */
  static Future<void> getMaxTalkers() async {
    await _channel.invokeMethod('getMaxTalkers');
  }

  /*
   To enable logs of EnxRTCiOS SDK.
   @param bool status true to enable and false to disable.
   @return void
  */
  static Future<void> enableLogs(bool status) async {
    await _channel.invokeMethod('enableLogs', {'status': status});
  }

  /*
   To post Enx client SDK logs to server use the below method.
   Note: To post client logs, first developer needs to enable the logs.
   @return void
 */
  static Future<void> postClientLogs() async {
    await _channel.invokeMethod('postClientLogs');
  }

  static void _removeEventChannelHandler() async {
    await _sink?.cancel();
  }

  /*
  This API is only available during Lecture Mode of a Session. Each Participant Raise hand Control can individually be asked to Join the floor using this API Call. This API calls are only available to users with role “Participant”
  @return void
  */
  static Future<void> requestFloor() async {
    await _channel.invokeMethod('requestFloor');
  }

  /*
  This API is only available during Lecture Mode. Each Participant requested Floor Control can individually be granted access to the Floor using this API Call.
  These API calls are only available to users with role “Moderator”.
  @param String clientId It’s the Client ID for the participant whom access is being granted.
  @return void
  */
  static Future<void> grantFloor(String clientId) async {
    await _channel.invokeMethod('grantFloor', {'clientId': clientId});
  }

  /*
  This API is only available during Lecture Mode. Each Participant requested Floor Control can individually be granted access to the Floor using this API Call.
  These API calls are only available to users with role “Moderator”.
  @param String clientId It’s the Client ID for the participant whom access is being granted.
  @return void
  */
  static Future<void> cancelFloor() async {
    await _channel.invokeMethod('cancelFloor');
  }

  /*
  This API is only available during Lecture Mode. Each Participant requested Floor Control can individually be granted access to the Floor using this API Call.
  These API calls are only available to users with role “Moderator”.
  @param String clientId It’s the Client ID for the participant whom access is being granted.
  @return void
  */
  static Future<void> finishFloor() async {
    await _channel.invokeMethod('finishFloor');
  }

  /*
  This API is only available during Lecture Mode of a Session. Each Participant requested Floor Control can individually be denied access to the Floor using this API Call.
  This API calls are only available to users with role “Moderator”.
  @param String clientId  It’s the Client ID for the participant who is being denied access to the floor.
  @return void
  */
  static Future<void> denyFloor(String clientId) async {
    await _channel.invokeMethod('denyFloor', {'clientId': clientId});
  }

  /*
  This API is only available during Lecture Mode of a Session. Each Participant granted Floor Control can individually be asked to release the floor Control using this API Call.
  This API calls are only available to users with role “Moderator”.
  @param String clientId It’s the Client ID for the participant who is being denied access to the floor.
  @return void
  */
  static Future<void> releaseFloor(String clientId) async {
    await _channel.invokeMethod('releaseFloor', {'clientId': clientId});
  }
//
  static Future<void> inviteToFloor(String clientId) async {
    await _channel.invokeMethod('inviteToFloor', {'clientId': clientId});
  }

  static Future<void> cancelFloorInvite(String clientId) async {
    await _channel.invokeMethod('cancelFloorInvite', {'clientId': clientId});
  }

  static Future<void> rejectInviteFloor(String clientId) async {
    await _channel.invokeMethod('rejectInviteFloor', {'clientId': clientId});
  }

  static Future<void> acceptInviteFloorRequest(String clientId) async {
    await _channel.invokeMethod('acceptInviteFloorRequest', {'clientId': clientId});
  }

  //


  /*
  To mute all other participants audio stream.
  Note: Hardmute functionality is only applicable to moderator.
  @return void
  */
  static Future<void> hardMute() async {
    await _channel.invokeMethod('hardMute');
  }

  /*
  To unmute all other participants audio stream.
  Note: Hardmute functionality is only applicable to moderator.
  @return void
  */
  static Future<void> hardUnMute() async {
    await _channel.invokeMethod('hardUnMute');
  }


  /*
   To mute  participants audio stream.
  Note: hardMuteAudio functionality is only applicable to moderator.
  @return void
  */
  static Future<void> hardMuteAudio(String clientId) async{
    await _channel.invokeMethod('hardMuteAudio', {'clientId': clientId});
  }
  /*
   To unmute  participants audio stream.
  Note: hardUnMuteAudio functionality is only applicable to moderator.
  @return void
  */
  static Future<void> hardUnMuteAudio(String clientId) async{
    await _channel.invokeMethod('hardUnMuteAudio', {'clientId': clientId});
  }

  /*
   To mute  participants video stream.
  Note: hardMuteVideo functionality is only applicable to moderator.
  @return void
  */
  static Future<void> hardMuteVideo(String clientId) async{
    await _channel.invokeMethod('hardMuteVideo', {'clientId': clientId});
  }
  /*
   To unmute  participants video stream.
  Note: hardUnMuteVideo functionality is only applicable to moderator.
  @return void
  */
  static Future<void> hardUnMuteVideo(String clientId) async{
    await _channel.invokeMethod('hardUnMuteVideo', {'clientId': clientId});
  }


  /*
   To Start screen share in the conference
  @return void
  */
  static Future<void> startScreenShare() async{
    await _channel.invokeMethod('startScreenShare');
  }

  /*
   To Stop screen share in the conference
  @return void
  */
  static Future<void> stopScreenShare() async{
    await _channel.invokeMethod('stopScreenShare');
  }


  /*
  To get Advance options set by client endpoint.
  @return void
  */
  static Future<void> getAdvancedOptions() async {
    await _channel.invokeMethod('getAdvancedOptions');
  }

  /*
  To lock room and no participant allow to join when room is lock.
  NOTE: This method is only for moderator.
  @return void
  */
  static Future<void> lockRoom() async {
    await _channel.invokeMethod('lockRoom');
  }

  /*
  To unlock room when room is locked.
  NOTE: This method is only for moderator.
  @return void
  */
  static Future<void> unLockRoom() async {
    await _channel.invokeMethod('unLockRoom');
  }

  /*
  To make outbound call using client number and callerId.
  @param String number
  @return void
  */
  static Future<void> makeOutboundCall(String number, String callerId) async {
    await _channel.invokeMethod(
        'makeOutboundCall', {'number': number, 'callerId': callerId});
  }
 /* static Future<void> makeOutboundCallWithDialerOption( String number, String callerId, Map<String, dynamic> dialOption) async {
    await _channel.invokeMethod(
        'makeOutboundCallWithDialerOption', {'number': number, 'callerId': callerId,'dialOptions':dialOption});
  }
  static Future<void> makeOutboundCallWithMultipleUser( List<dynamic> number,  String callerId,Map<String, dynamic> dialOption) async {
    await _channel.invokeMethod(
        'makeOutboundCallWithMultipleUser', {'number': number, 'callerId': callerId,'dialOptions':dialOption});
  }
*/
  /*
  To extend conference duration.
  @return void
  */
  static Future<void> extendConferenceDuration() async {
    await _channel.invokeMethod('extendConferenceDuration');
  }

  /*
  To disconnect all the participants present in the room.
  NOTE: This method is only for moderator.
  @return void
  */
  static Future<void> destroy() async {
    await _channel.invokeMethod('destroy');
  }

  /* Client endpoint will call this method to a mute/unmute remote stream while application in the foreground. */
  static Future<void> startVideoTracksOnApplicationForeground(
      bool restoreVideoRemoteStream, bool restoreVideoLocalStream) async {
    await _channel.invokeMethod('startVideoTracksOnApplicationForeground', {
      'restoreVideoRemoteStream': restoreVideoRemoteStream,
      'restoreVideoLocalStream': restoreVideoLocalStream
    });
  }

  /* Client endpoint will call this method to a mute/unmute remote stream while application in the background. */
  static Future<void> stopVideoTracksOnApplicationBackground(
      bool videoMuteLocalStream, bool videoMuteRemoteStream) async {
    await _channel.invokeMethod('stopVideoTracksOnApplicationBackground', {
      'videoMuteLocalStream': videoMuteLocalStream,
      'videoMuteRemoteStream': videoMuteRemoteStream
    });
  }

  /* To run the call on audio only mode. True to enable and false to disable  */
  static Future<void> setAudioOnlyMode(bool audioOnly) async {
    await _channel.invokeMethod('setAudioOnlyMode', {'audioOnly': audioOnly});
  }

  /* This method Will Switch to selected media device */
  static Future<void> switchMediaDevice(String deviceName) async {
    await _channel
        .invokeMethod('switchMediaDevice', {'deviceName': deviceName});
  }

  /*Client endpoint can use this method to switch role moderator can pass the role to any participant.*/
  static Future<void> switchUserRole(String clientId) async {
    await _channel.invokeMethod('switchUserRole', {'clientId': clientId});
  }

  /*
  Client End point will call this method to enable/disable stats by passing flag = true/false
 'True' for enable stats and 'False' for desable Stats
  */
  static Future<void> enableStats(bool enableStats) async {
    await _channel.invokeMethod('enableStats', {'enableStats': enableStats});
  }

  /*
  Client End point will call this method to enable/disable stats by passing flag = true/false
 'True' for enable stats and 'False' for desable Stats
  */
  static Future<void> enableProximitySensor(bool isEnabled) async {
    await _channel
        .invokeMethod('enableProximitySensor', {'isEnabled': isEnabled});
  }

  /*
  Client end point use this method to active/inactive audio of all subcribe streams.
  */
  static Future<void> muteSubscribeStreamsAudio(bool isMute) async {
    await _channel
        .invokeMethod('muteSubscribeStreamsAudio', {'isMute': isMute});
  }

  /*To send chat message to the other clients.
  @param String message text to send to other clients.
  @param bool isBroadCast true to send all the clients and false to send given recipientIDs.
  @param List<dynamic> recipientIDs
   */
  static Future<void> sendMessage(
      String message, bool isBroadCast, List<dynamic> recipientIDs) async {
    await _channel.invokeMethod('sendMessage', {
      'message': message,
      'isBroadCast': isBroadCast,
      'recipientIDs': recipientIDs,
    });
  }

  /*To send custom chat message to the other clients.
  @param String message text to send to other clients.
  @param bool isBroadCast true to send all the clients and false to send given recipientIDs.
  @param List<dynamic> recipientIDs
   */
  static Future<void> sendUserData(Map<String, dynamic> message,
      bool isBroadCast, List<dynamic> recipientIDs) async {
    await _channel.invokeMethod('sendUserData', {
      'message': message,
      'isBroadCast': isBroadCast,
      'recipientIDs': recipientIDs,
    });
  }

  /*To send files to the other clients.
  @param bool isBroadCast true to send all the clients and false to send given recipientIDs.
  @param List<dynamic> clientIds
   */
  static Future<void> sendFiles(
      bool isBroadCast, List<dynamic> clientIds) async {
    await _channel.invokeMethod('sendFiles', {
      'isBroadCast': isBroadCast,
      'recipientIDs': clientIds,
    });
  }

  /*To cancel upload files to the other clients.
  @param int jobId
   */
  static Future<void> cancelUpload(int jobId) async {
    await _channel.invokeMethod('cancelUpload', {'jobId': jobId});
  }

  /*To cancel all upload files to the other clients.*/
  static Future<void> cancelAllUploads() async {
    await _channel.invokeMethod('cancelAllUploads');
  }

  /*To cancel download files to the other clients.
  @param int jobId
   */
  static Future<void> cancelDownload(int jobId) async {
    await _channel.invokeMethod('cancelDownload', {'jobId': jobId});
  }

  /*To cancel all downloads files to the other clients.*/
  static Future<void> cancelAllDownloads() async {
    await _channel.invokeMethod('cancelAllDownloads');
  }

  /*To download files received.
  @param Map<String, dynamic> file
  @param bool autoSave
   */
  static Future<void> downloadFile(
      Map<dynamic, dynamic> file, bool autoSave) async {
    await _channel
        .invokeMethod('downloadFile', {'file': file, 'autoSave': autoSave});
  }

  /*To update the stream config
  @param Map<String, dynamic> config
   */
  static Future<void> updateConfiguration(Map<String, dynamic> config) async {
    await _channel.invokeMethod('updateConfiguration', {'config': config});
  }

  /* Get all available users in connected room
   return  <List<dynamic>
  */
  static Future<List<dynamic>> getUserList() async {
    final List<dynamic> result = await _channel.invokeMethod("getUserList");
    print(result);
    return result;
  }

  /*
      streamType which should be "talker/canvas"
      This API use to return the remote video stream quality.
   */
  static Future<String> getReceiveVideoQuality(String streamType) async {
    final String result = await _channel
        .invokeMethod("getReceiveVideoQuality", {'streamType', streamType});
    return result;
  }

  /*
      This method returns user-meta information about the user connected on a End-POint.
      @returns Map<String, dynamic>
   */
  static Future<Map<String, dynamic>> whoAmI() async {
    final Map<String, dynamic> result = await _channel.invokeMethod("whoAmI");
    return result;
  }

  /* This method Will return all list of connected Audio Device
    @returns List<dynamic>
   */
  static Future<List<dynamic>> getDevices() async {
    final List<dynamic> result = await _channel.invokeMethod("getDevices", {});
    return result;
  }

  /* This method Will return Current selected Audio device
    @returns String
  */
  static Future<String> getSelectedDevice() async {
    final String result = await _channel.invokeMethod("getSelectedDevice");
    return result;
  }

  /*To get all available files
   @return List<dynamic>
   */
  static Future<List<dynamic>> getAvailableFiles() async {
    final List<dynamic> result =
        await _channel.invokeMethod("getAvailableFiles", {});
    return result;
  }

  /*To drop/disconnect other clients.
   NOTE: This method is only for modeartor.
   */
  static Future<void> dropUser(List<dynamic> clientIds) async {
    await _channel.invokeMethod('dropUser', {'clientIds': clientIds});
  }

  /* To get roomId. */
  static Future<String> getRoomId() async {
    final String result = await _channel.invokeMethod('getRoomId');
    return result;
  }

  /* To get self client Name. */
  static Future<String> getClientName() async {
    final String result = await _channel.invokeMethod('getClientName');
    return result;
  }

  /* To get self client role. */
  static Future<String> getRole() async {
    final String result = await _channel.invokeMethod('getRole');
    return result;
  }

  /* To get self client Id. */
  static Future<String> getClientId() async {
    final String result = await _channel.invokeMethod('getClientId');
    return result;
  }

  static Future<bool> isRoomActiveTalker() async {
    final bool status = await _channel.invokeMethod('isRoomActiveTalker');
    return status;
  }

  /* To set advance option in the connected room
    @param List<dynamic> advanceOptions list of advance options
   */
  static Future<void> setAdvancedOptions(List<dynamic> advanceOptions) async {
    await _channel.invokeMethod('setAdvancedOptions', {
      'advanceOptions': advanceOptions,
    });
  }

  static Future<void> setupVideo(
      int viewId, int uid, bool isLocal, int width, int height) async {
    // System.out.println("setupView "+viewId.toString()+uid.toString());
    await _channel.invokeMethod('setupVideo', {
      'viewId': viewId,
      'uid': uid,
      'isLocal': isLocal,
      'width': width,
      'height': height
    });
  }

  static Future<void> setupToolbar(int width, int height) async {
    await _channel.invokeMethod('setupToolbar', {
      'width': width,
      'height': height
    });
  }

  static Future<void> setZOrderMediaOverlay(
      int viewId, int uid, bool mediaOverlay) async {
    await _channel.invokeMethod('setZOrderMediaOverlay', {
      'viewId': viewId,
      'uid': uid,
      'mediaOverlay': mediaOverlay,
    });
  }

  static Future<void> setPlayerScalingType(
      ScalingType scalingType, int viewId, int uid, bool isLocal) async {
    await _channel.invokeMethod('setPlayerScalingType', {
      'type': scalingType.toString(),
      'viewId': viewId,
      'uid': uid,
      'isLocal': isLocal,
    });
  }

  static Future<void> muteSelfAudio(bool isMute) async {
    await _channel.invokeMethod('muteSelfAudio', {
      'isMute': isMute,
    });
  }

  static Future<void> muteSelfVideo(bool isMute) async {
    await _channel.invokeMethod('muteSelfVideo', {
      'isMute': isMute,
    });
  }

  static Future<void> captureScreenShot(String streamId) async {
    await _channel.invokeMethod('captureScreenShot', {
      'streamId': streamId,
    });
  }

  /*Pin user api*/
  static Future<void> pinUsers(List<dynamic> userList) async {
    await _channel.invokeMethod('pinUsers', {
      'userList': userList,
    });
  }

/*Unpin user api*/
  static Future<void> unpinUsers(List<dynamic> userList) async {
    await _channel.invokeMethod('unpinUsers', {
      'userList': userList,
    });
  }

  /*Create Breakout Room Api*/
  static Future<void> createBreakOutRoom(
      Map<String, dynamic> createBreakoutInfo) async {
    await _channel.invokeMethod(
        'createBreakOutRoom', {'createBreakoutInfo': createBreakoutInfo});
  }

  /*CreateAndInvite Breakout Room  Api*/
  static Future<void> createAndInviteBreakoutRoom(
      Map<String, dynamic> createandInviteBreakOutInfo) async {
    await _channel.invokeMethod('createAndInviteBreakoutRoom',
        {'createandInviteBreakOutInfo': createandInviteBreakOutInfo});
  }

  /* Join BreakOut Room Api*/
  static Future<void> joinBreakOutRoom(
      Map<String, dynamic> dataInfo, Map<String, dynamic> streamInfo) async {
    await _channel.invokeMethod(
        'joinBreakOutRoom', {'dataInfo': dataInfo, 'streamInfo': streamInfo});
  }

  /*InviteToBreakOut Room Api*/

  static Future<void> inviteToBreakOutRoom(
      Map<String, dynamic> inviteBreakOutInfo) async {
    await _channel.invokeMethod(
        'inviteToBreakOutRoom', {'inviteBreakOutInfo': inviteBreakOutInfo});
  }

  /*Pause Breakout Room  Api*/

  static Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  /* Resume BreakOut Room Api*/

  static Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  /*Mute Room  Api*/
  static Future<void> muteRoom(Map<String, dynamic> muteRoomInfo) async {
    await _channel.invokeMethod('muteRoom', {'muteRoomInfo': muteRoomInfo});
  }

  /*UnMute Room  Api*/
  static Future<void> unmuteRoom(Map<String, dynamic> unMuteRoomInfo) async {
    await _channel
        .invokeMethod('unmuteRoom', {'unMuteRoomInfo': unMuteRoomInfo});
  }

  /*reject Breakout room Api */

  static Future<void> rejectBreakOutRoom(String brekoutRoomId) async {
    await _channel
        .invokeMethod('rejectBreakOutRoom', {'breakoutRoomId': brekoutRoomId});

  }


/*Pre-call test clientDiagnostics*/
  static Future<void> clientDiagnostics(Map<String, dynamic> optionInfo) async {
    await _channel
        .invokeMethod('clientDiagnostics', {'optionInfo': optionInfo});
    _addEventChannelHandler();
  }

  /*Subscribe Talker Notification*/
  static Future<void> subscribeForTalkerNotification(
      bool isTalkerNotification) async {
    await _channel.invokeMethod('subscribeForTalkerNotification',
        {'isTalkerNotification': isTalkerNotification});
  }

  /*
   * Use to approve participant who are waiting to join the room
   * This api is only for moderator
   */
  static Future<void> approveAwaitedUser(String clintId) async {
    await _channel.invokeMethod('approveAwaitedUser', {'clientId': clintId});
  }

  /*
   * Use to deny participant who are waiting to join the room
   * This api is only for moderator
   */
  static Future<void> denyAwaitedUser(String clintId) async {
    await _channel.invokeMethod('denyAwaitedUser', {'clientId': clintId});
  }

  //Spot light user
  /*addSpotlightUsers user api*/
  static Future<void> addSpotlightUsers(List<dynamic> userList) async {
    await _channel.invokeMethod('addSpotlightUsers', {
      'userList': userList,
    });
  }

/*removeSpotlightUsers user api*/
  static Future<void> removeSpotlightUsers(List<dynamic> userList) async {
    await _channel.invokeMethod('removeSpotlightUsers', {
      'userList': userList,
    });
  }

  /*Switch Room mode user api*/
  static Future<void> switchRoomMode(String mode) async {
    await _channel.invokeMethod('switchRoomMode', {
      'roomMode': mode,
    });
  }

  /*Start Live Streaming */
  static Future<void> startStreaming(Map<String, dynamic> streamingDetails) async {
    await _channel
        .invokeMethod('startStreaming', {'streamingDetails': streamingDetails});

  }

  /*Stop Live Streaming */
  static Future<void> stopStreaming(Map<String, dynamic> streamingDetails) async {
    await _channel
        .invokeMethod('stopStreaming', {'streamingDetails': streamingDetails});

  }
  /*start Live Recording */
  static Future<void> startLiveRecording(Map<String, dynamic> streamingDetails) async {
    await _channel
        .invokeMethod('startLiveRecording', {'streamingDetails': streamingDetails});

  }

  /*Stop Live Recording */
  static Future<void> stopLiveRecording() async {
    await _channel
        .invokeMethod('stopLiveRecording');

  }

  //Cancel outbound Call
  static Future<void> cancelOutboundCall(String number)async{
    await _channel
        .invokeMethod('cancelOutboundCall',{'number':number});

  }

  /*  Single Mute/Unmute Audio  */
  static Future<void> hardMuteUserAudio(String clientId) async{
    await _channel.invokeMapMethod('hardMuteUserAudio',{'clientId': clientId});
  }
  static Future<void> hardUnmuteUserAudio(String clientId) async{
    await _channel.invokeMapMethod('hardUnmuteUserAudio',{'clientId': clientId});
  }
/*  Single Mute/Unmute Video  */
  static Future<void> hardMuteUserVideo(String clientId) async{
    await _channel.invokeMapMethod('hardMuteUserVideo',{'clientId': clientId});
  }
  static Future<void> hardUnmuteUserVideo(String clientId) async{
    await _channel.invokeMapMethod('hardUnmuteUserVideo',{'clientId': clientId});
  }

  static Future<void> highlightBorderForClient(List<dynamic>  clientId) async{
    await _channel.invokeMapMethod('highlightBorderForClient',{'clientId': clientId});
  }
  static Future<void> changeBgColorForClients(List<dynamic>  clientId,String color) async{
    await _channel.invokeMapMethod('changeBgColorForClients',{'clientId': clientId,'color':color});
  }


  /*
   To Start Annotation in the conference
  @return void
  */
  static Future<void> startAnnotation(String streamId) async{
    await _channel.invokeMethod('startAnnotation', {
      'streamId': streamId,
    });
  }

  /*
   To Stop Annotation in the conference
  @return void
  */
  static Future<void> stopAnnotation() async{
    await _channel.invokeMethod('stopAnnotation');
  }

  /*
   To Start Live startLiveTranscription in the conference
  @return void
  */
  static Future<void> startLiveTranscription(String language) async{
    await _channel.invokeMethod('startLiveTranscription', {
      'language': language,
    });
  }

  /*
   To Start Live startLiveTranscription in the conference
  @return void
  */
  static Future<void> startLiveTranscriptionForRoom(String language) async{
    await _channel.invokeMethod('startLiveTranscriptionForRoom', {
      'language': language,
    });
  }
/*
   To Start Live stopLiveTranscription in the conference
  @return void
  */

  static Future<void> stopLiveTranscription() async{
    await _channel.invokeMethod('stopLiveTranscription');
  }






  /// Creates the video renderer Widget.
  /// The Widget is identified by viewId, the operation and layout of the Widget are managed by the app.
  static Widget createNativeView(Function(int viewId) created, {Key? key}) {
    print('*****enxrtc******' + key.toString());
    if (Platform.isIOS) {
      return UiKitView(
        key: key,
        viewType: 'EnxPlayer',
        onPlatformViewCreated: (viewId) {
          print('*****This is the iOS enxrtc******' + viewId.toString());
          created(viewId);
          print('enxRtc view created' + viewId.toString());
        },
      );
    } else {
      return AndroidView(
        key: key,
        viewType: 'EnxPlayer',
        onPlatformViewCreated: (viewId) {
         print('*****This is the iOS enxrtc******' + viewId.toString());
          created(viewId);
        },
      );
    }
  }

  /// Creates the video renderer Widget.
  /// The Widget is identified by viewId, the operation and layout of the Widget are managed by the app.
  static Widget createToolbarView(Function(int viewId) created, {Key? key}) {
    print('*****enxrtc******' + key.toString());
    if (Platform.isIOS) {
      return UiKitView(
        key: key,
        viewType: 'EnxToolbarView',
        onPlatformViewCreated: (viewId) {
          print('*****This is the Toolbar enxrtc******' + viewId.toString());
          created(viewId);
          print('enxRtc view created' + viewId.toString());
        },
      );
    } else {
      return AndroidView(
        key: key,
        viewType: 'EnxToolbarView',
        onPlatformViewCreated: (viewId) {
          print('*****This is the Toolbar enxrtc******' + viewId.toString());
          created(viewId);
        },
      );
    }
  }


  /// Remove the video renderer Widget.
  static Future<void> removeNativeView(int viewId) async {
    print("uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu$viewId");
    await _channel.invokeMethod('removeNativeView', {'viewId': viewId});
  }

  static void _eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    //logger.e('mappppp' + map);
    switch (map['event']) {
      // Core Events

      case 'onRoomConnected':
        if (onRoomConnected != null) {
          map.remove("event");
          onRoomConnected!(map);
        }
        break;
      case 'onRoomError':
        if (onRoomError != null) {
          map.remove("event");
          onRoomError!(map);
        }
        break;
      case 'onRoomDisConnected':
        if (onRoomDisConnected != null) {
          map.remove("event");
          onRoomDisConnected!(map);
          _removeEventChannelHandler();
        }
        break;
      case 'onPublishedStream':
        if (onPublishedStream != null) {
          map.remove("event");
          onPublishedStream!(map);
        }
        break;
      case 'onSubscribedStream':
        if (onSubscribedStream != null) {
          map.remove("event");
          onSubscribedStream!(map);
        }
        break;
      case 'onStreamAdded':
        if (onStreamAdded != null) {
          map.remove("event");
          onStreamAdded!(map);
        }
        break;
      case 'onUserConnected':
        if (onUserConnected != null) {
          map.remove("event");
          onUserConnected!(map);
        }
        break;
      case 'onUserDisConnected':
        if (onUserDisConnected != null) {
          map.remove("event");
          onUserDisConnected!(map);
        }
        break;
      case 'onUserDataReceived':
        if (onUserDataReceived != null) {
          map.remove("event");
          onUserDataReceived!(map);
        }
        break;
      case 'onMessageReceived':
        if (onMessageReceived != null) {
          map.remove("event");
          onMessageReceived!(map);
        }
        break;
      case 'onAcknowledgedSendData':
        if (onAcknowledgedSendData != null) {
          map.remove("event");
          onAcknowledgedSendData!(map);
        }
        break;
      case 'onEventInfo':
        if (onEventInfo != null) {
          map.remove("event");
          onEventInfo!(map);
        }
        break;
      case 'onEventError':
        if (onEventError != null) {
          map.remove("event");
          onEventError!(map);
        }
        break;
      case 'onActiveTalkerList':
        if (onActiveTalkerList != null) {
          map.remove("event");
          onActiveTalkerList!(map);
        }
        break;
      case 'onSwitchedUserRole':
        if (onSwitchedUserRole != null) {
          map.remove("event");
          onSwitchedUserRole!(map);
        }
        break;
      case 'onAckDestroy':
        if (onAckDestroy != null) {
          map.remove("event");
          onAckDestroy!(map);
        }
        break;
      case 'onAckDropUser':
        if (onAckDropUser != null) {
          map.remove("event");
          onAckDropUser!(map);
        }
        break;
      case 'onConferenceRemainingDuration':
        if (onConferenceRemainingDuration != null) {
          map.remove("event");
          onConferenceRemainingDuration!(map);
        }
        break;
      case 'onConferencessExtended':
        if (onConferencessExtended != null) {
          map.remove("event");
          onConferencessExtended!(map);
        }
        break;
      case 'onRoomRecordingOn':
        if (onRoomRecordingOn != null) {
          map.remove("event");
          onRoomRecordingOn!(map);
        }
        break;
      case 'onRoomRecordingOff':
        if (onRoomRecordingOff != null) {
          map.remove("event");
          onRoomRecordingOff!(map);
        }
        break;
      case 'onStartRecordingEvent':
        if (onStartRecordingEvent != null) {
          map.remove("event");
          onStartRecordingEvent!(map);
        }
        break;
      case 'onStopRecordingEvent':
        if (onStopRecordingEvent != null) {
          map.remove("event");
          onStopRecordingEvent!(map);
        }
        break;
      case 'onMaxTalkerCount':
        if (onMaxTalkerCount != null) {
          map.remove("event");
          onMaxTalkerCount!(map);
        }
        break;
      case 'onGetTalkerCount':
        if (onGetTalkerCount != null) {
          map.remove("event");
          onGetTalkerCount!(map);
        }
        break;
      case 'onSetTalkerCount':
        if (onSetTalkerCount != null) {
          map.remove("event");
          onSetTalkerCount!(map);
        }
        break;
      case 'onLogUploaded':
        if (onLogUploaded != null) {
          map.remove("event");
          onLogUploaded!(map);
        }
        break;
      case 'onBandWidthUpdated':
        if (onBandWidthUpdated != null) {
          map.remove("event");
          onBandWidthUpdated!(map);
        }
        break;
      case 'onShareStreamEvent':
        if (onShareStreamEvent != null) {
          map.remove("event");
          onShareStreamEvent!(map);
        }
        break;
      case 'onCanvasStreamEvent':
        if (onCanvasStreamEvent != null) {
          map.remove("event");
          onCanvasStreamEvent!(map);
        }
        break;
      case 'onConnectionInterrupted':
        if (onConnectionInterrupted != null) {
          map.remove("event");
          onConnectionInterrupted!(map);
        }
        break;
      case 'onConnectionLost':
        if (onConnectionLost != null) {
          map.remove("event");
          onConnectionLost!(map);
        }
        break;
      case 'onFloorRequested':
        if (onFloorRequested != null) {
          map.remove("event");
          onFloorRequested!(map);
        }
        break;
      case 'onFloorRequestReceived':
        if (onFloorRequestReceived != null) {
          map.remove("event");
          onFloorRequestReceived!(map);
        }
        break;
      case 'onProcessFloorRequested':
        if (onProcessFloorRequested != null) {
          map.remove("event");
          onProcessFloorRequested!(map);
        }
        break;
      case 'onGrantedFloorRequest':
        if (onGrantedFloorRequest != null) {
          map.remove("event");
          onGrantedFloorRequest!(map);
        }
        break;
      case 'onDeniedFloorRequest':
        if (onDeniedFloorRequest != null) {
          map.remove("event");
          onDeniedFloorRequest!(map);
        }
        break;
      case 'onReleasedFloorRequest':
        if (onReleasedFloorRequest != null) {
          map.remove("event");
          onReleasedFloorRequest!(map);
        }
        break;
      case 'onReceivedHardUnMute':
        if (onReceivedHardUnMute != null) {
          map.remove("event");
          onReceivedHardUnMute!(map);
        }
        break;
      case 'onHardUnMuted':
        if (onHardUnMuted != null) {
          map.remove("event");
          onHardUnMuted!(map);
        }
        break;
      case 'onReceivedHardMute':
        if (onReceivedHardMute != null) {
          map.remove("event");
          onReceivedHardMute!(map);
        }
        break;
      case 'onHardMuted':
        if (onHardMuted != null) {
          map.remove("event");
          onHardMuted!(map);
        }
        break;
      case 'onAudioEvent':
        if (onAudioEvent != null) {
          map.remove("event");
          onAudioEvent!(map);
        }
        break;
      case 'onVideoEvent':
        if (onVideoEvent != null) {
          map.remove("event");
          onVideoEvent!(map);
        }
        break;
      case 'onReceivedData':
        if (onReceivedData != null) {
          map.remove("event");
          onReceivedData!(map);
        }
        break;
      case 'onRemoteStreamAudioMute':
        if (onRemoteStreamAudioMute != null) {
          map.remove("event");
          onRemoteStreamAudioMute!(map);
        }
        break;
      case 'onRemoteStreamAudioUnMute':
        if (onRemoteStreamAudioUnMute != null) {
          map.remove("event");
          onRemoteStreamAudioUnMute!(map);
        }
        break;
      case 'onRemoteStreamVideoMute':
        if (onRemoteStreamVideoMute != null) {
          map.remove("event");
          onRemoteStreamVideoMute!(map);
        }
        break;
      case 'onRemoteStreamVideoUnMute':
        if (onRemoteStreamVideoUnMute != null) {
          map.remove("event");
          onRemoteStreamVideoUnMute!(map);
        }
        break;
      case 'onAdvancedOptionsUpdate':
        if (onAdvancedOptionsUpdate != null) {
          map.remove("event");
          onAdvancedOptionsUpdate!(map);
        }
        break;
      case 'onGetAdvancedOptions':
        if (onGetAdvancedOptions != null) {
          map.remove("event");
          onGetAdvancedOptions!(map);
        }
        break;
      case 'onAckLockRoom':
        if (onAckLockRoom != null) {
          map.remove("event");
          onAckLockRoom!(map);
        }
        break;
      case 'onAckUnLockRoom':
        if (onAckUnLockRoom != null) {
          map.remove("event");
          onAckUnLockRoom!(map);
        }
        break;
      case 'onLockedRoom':
        if (onLockedRoom != null) {
          map.remove("event");
          onLockedRoom!(map);
        }
        break;
      case 'onUnLockedRoom':
        if (onUnLockedRoom != null) {
          map.remove("event");
          onUnLockedRoom!(map);
        }
        break;
      case 'onOutBoundCallInitiated':
        if (onOutBoundCallInitiated != null) {
          map.remove("event");
          onOutBoundCallInitiated!(map);
        }
        break;
      case 'onHardMutedAudio':
        if (onHardMutedAudio != null) {
          map.remove("event");
          onHardMutedAudio!(map);
        }
        break;
      case 'onHardUnMutedAudio':
        if (onHardUnMutedAudio != null) {
          map.remove("event");
          onHardUnMutedAudio!(map);
        }
        break;
      case 'onReceivedHardMuteAudio':
        if (onReceivedHardMuteAudio != null) {
          map.remove("event");
          onReceivedHardMuteAudio!(map);
        }
        break;
      case 'onReceivedHardUnMuteAudio':
        if (onReceivedHardUnMuteAudio != null) {
          map.remove("event");
          onReceivedHardUnMuteAudio!(map);
        }
        break;

      case 'onHardMutedVideo':
        if (onHardMutedVideo != null) {
          map.remove("event");
          onHardMutedVideo!(map);
        }
        break;
      case 'onHardUnMutedVideo':
        if (onHardUnMutedVideo != null) {
          map.remove("event");
          onHardUnMutedVideo!(map);
        }
        break;
      case 'onReceivedHardMuteVideo':
        if (onReceivedHardMuteVideo != null) {
          map.remove("event");
          onReceivedHardMuteVideo!(map);
        }
        break;
      case 'onReceivedHardUnMuteVideo':
        if (onReceivedHardUnMuteVideo != null) {
          map.remove("event");
          onReceivedHardUnMuteVideo!(map);
        }
        break;
      case 'onReconnect':
        if (onReconnect != null) {
          map.remove("event");
          onReconnect!(map['msg']);
        }
        break;
      case 'onNotifyDeviceUpdate':
        if (onNotifyDeviceUpdate != null) {
          map.remove("event");
          onNotifyDeviceUpdate!(map['msg']);
        }
        break;
      case 'onDialStateEvents':
        if (onDialStateEvents != null) {
          map.remove("event");
          onDialStateEvents!(map['state']);
        }
        break;
      case 'onDialStateEvent':
        if (onDialStateEvent != null) {
          map.remove("event");
          onDialStateEvent!(map);
        }
        break;
      case 'onDTMFCollecteds':
        if (onDTMFCollecteds != null) {
          map.remove("event");
          onDTMFCollecteds!(map);
        }
        break;
      case 'onOutBoundCallCancel':
        if (onOutBoundCallCancel != null) {
          map.remove("event");
          onOutBoundCallCancel!(map);
        }
        break;
      case 'onDTMFCollected':
        if (onDTMFCollected != null) {
          map.remove("event");
          onDTMFCollected!(map['msg']);
        }
        break;
      case 'OnCapturedView':
        if (OnCapturedView != null) {
          map.remove("event");
          OnCapturedView!(map['bitmap']);
        }
        break;
      case 'onUserReconnectSuccess':
        if (onUserReconnectSuccess != null) {
          map.remove("event");
          onUserReconnectSuccess!(map);
        }
        break;
      case 'onScreenSharedStarted':
        if (onScreenSharedStarted != null) {
          map.remove("event");
          onScreenSharedStarted!(map);
        }
        break;
      case 'onStartScreenShareACK':
        if (onStartScreenShareACK != null) {
          map.remove("event");
          onStartScreenShareACK!(map);
        }
        break;
      case 'onStoppedScreenShareACK':
        if (onStoppedScreenShareACK != null) {
          map.remove("event");
          onStoppedScreenShareACK!(map);
        }
        break;
      case 'onExitScreenShareACK':
        if (onExitScreenShareACK != null) {
          map.remove("event");
          onExitScreenShareACK!(map);
        }
        break;

      case 'onScreenSharedStopped':
        if (onScreenSharedStopped != null) {
          map.remove("event");
          onScreenSharedStopped!(map);
        }
        break;
      case 'onCanvasStarted':
        if (onCanvasStarted != null) {
          map.remove("event");
          onCanvasStarted!(map);
        }
        break;
      case 'onCanvasStopped':
        if (onCanvasStopped != null) {
          map.remove("event");
          onCanvasStopped!(map);
        }
        break;
      case 'onFileUploadStarted':
        if (onFileUploadStarted != null) {
          map.remove("event");
          onFileUploadStarted!(map);
        }
        break;
      case 'onFileAvailable':
        if (onFileAvailable != null) {
          map.remove("event");
          onFileAvailable!(map);
        }
        break;
      case 'onInitFileUpload':
        if (onInitFileUpload != null) {
          map.remove("event");
          onInitFileUpload!(map);
        }
        break;
      case 'onFileUploaded':
        if (onFileUploaded != null) {
          map.remove("event");
          onFileUploaded!(map);
        }
        break;
      case 'onFileUploadCancelled':
        if (onFileUploadCancelled != null) {
          map.remove("event");
          onFileUploadCancelled!(map);
        }
        break;
      case 'onFileUploadFailed':
        if (onFileUploadFailed != null) {
          map.remove("event");
          onFileUploadFailed!(map);
        }
        break;
      case 'onFileDownloaded':
        if (onFileDownloaded != null) {
          map.remove("event");
          onFileDownloaded!(map);
        }
        break;
      case 'onFileDownloadCancelled':
        if (onFileDownloadCancelled != null) {
          map.remove("event");
          onFileDownloadCancelled!(map);
        }
        break;
      case 'onFileDownloadFailed':
        if (onFileDownloadFailed != null) {
          map.remove("event");
          onFileDownloadFailed!(map);
        }
        break;
      case 'onInitFileDownload':
        if (onInitFileDownload != null) {
          map.remove("event");
          onInitFileDownload!(map);
        }
        break;
      case 'onAcknowledgeStats':
        if (onAcknowledgeStats != null) {
          map.remove("event");
          onAcknowledgeStats!(map);
        }
        break;
      case 'onReceivedStats':
        if (onReceivedStats != null) {
          map.remove("event");
          onReceivedStats!(map);
        }
        break;
      case 'onCancelledFloorRequest':
        if (onCancelledFloorRequest != null) {
          map.remove("event");
          onCancelledFloorRequest!(map);
        }
        break;
      case 'onFinishedFloorRequest':
        if (onFinishedFloorRequest != null) {
          map.remove("event");
          onFinishedFloorRequest!(map);
        }
        break;
      case 'onFloorCancelled':
        if (onFloorCancelled != null) {
          map.remove("event");
          onFloorCancelled!(map);
        }
        break;
      case 'onFloorFinished':
        if (onFloorFinished != null) {
          map.remove("event");
          onFloorFinished!(map);
        }
        break;
      case 'onACKInviteToFloorRequested':
        if (onACKInviteToFloorRequested != null) {
          map.remove("event");
          onACKInviteToFloorRequested!(map);
        }
        break;
      case 'onInviteToFloorRequested':
        if (onInviteToFloorRequested != null) {
          map.remove("event");
          onInviteToFloorRequested!(map);
        }
        break;
      case 'onInvitedForFloorAccess':
        if (onInvitedForFloorAccess != null) {
          map.remove("event");
          onInvitedForFloorAccess!(map);
        }
        break;
      case 'onCanceledFloorInvite':
        if (onCanceledFloorInvite != null) {
          map.remove("event");
          onCanceledFloorInvite!(map);
        }
        break;
      case 'onRejectedInviteFloor':
        if (onRejectedInviteFloor != null) {
          map.remove("event");
          onRejectedInviteFloor!(map);
        }
        break;
      case 'onAcceptedFloorInvite':
        if (onAcceptedFloorInvite != null) {
          map.remove("event");
          onAcceptedFloorInvite!(map);
        }
        break;
      case 'onAckPinUsers':
        if (onAckPinUsers != null) {
          map.remove("event");
          onAckPinUsers!(map);
        }
        break;
      case 'onAckUnpinUsers':
        if (onAckUnpinUsers != null) {
          map.remove("event");
          onAckUnpinUsers!(map);
        }
        break;
      case 'onPinnedUsers':
        if (onPinnedUsers != null) {
          map.remove("event");
          onPinnedUsers!(map);
        }
        break;
      case 'onRoomAwaited':
        if (onRoomAwaited != null) {
          map.remove("event");
          onRoomAwaited!(map);
        }
        break;
      case 'onUserAwaited':
        if (onUserAwaited != null) {
          map.remove("event");
          onUserAwaited!(map);
        }
        break;
      case 'onAckForApproveAwaitedUser':
        if (onAckForApproveAwaitedUser != null) {
          map.remove("event");
          onAckForApproveAwaitedUser!(map);
        }
        break;
      case 'onAckForDenyAwaitedUser':
        if (onAckForDenyAwaitedUser != null) {
          map.remove("event");
          onAckForDenyAwaitedUser!(map);
        }
        break;
      case 'onRoomBandwidthAlert':
        if (onRoomBandwidthAlert != null) {
          map.remove("event");
          onRoomBandwidthAlert!(map);
        }
        break;
      case 'onStopAllSharingACK':
        if (onStopAllSharingACK != null) {
          map.remove("event");
          onStopAllSharingACK!(map);
        }
        break;


      case 'onAckSubscribeTalkerNotification':
        if (onAckSubscribeTalkerNotification != null) {
          map.remove("event");
          onAckSubscribeTalkerNotification!(map);
        }
        break;
      case 'onAckUnsubscribeTalkerNotification':
        if (onAckUnsubscribeTalkerNotification != null) {
          map.remove("event");
          onAckUnsubscribeTalkerNotification!(map);
        }
        break;
      case 'onTalkerNtification':
        if (onTalkerNtification != null) {
          map.remove("event");
          onTalkerNtification!(map);
        }
        break;
      case 'onClientDiagnosisFailed':
        if (onClientDiagnosisFailed != null) {
          map.remove("event");
          onClientDiagnosisFailed!(map);
        }
        break;
      case 'onClientDiagnosisStopped':
        if (onClientDiagnosisStopped != null) {
          map.remove("event");
          onClientDiagnosisStopped!(map);
        }
        break;
      case 'onClientDiagnosisFinished':
        if (onClientDiagnosisFinished != null) {
          map.remove("event");
          onClientDiagnosisFinished!(map);
        }
        break;
      case 'onClientDiagnosisStatus':
        if (onClientDiagnosisStatus != null) {
          map.remove("event");
          onClientDiagnosisStatus!(map);
        }
        break;
      case 'onAckCreateBreakOutRoom':
        if (onAckCreateBreakOutRoom != null) {
          map.remove("event");
          onAckCreateBreakOutRoom!(map);
        }
        break;
      case 'onAckCreateAndInviteBreakOutRoom':
        if (onAckCreateAndInviteBreakOutRoom != null) {
          map.remove("event");
          onAckCreateAndInviteBreakOutRoom!(map);
        }
        break;
      case 'onAckInviteBreakOutRoom':
        if (onAckInviteBreakOutRoom != null) {
          map.remove("event");
          onAckInviteBreakOutRoom!(map);
        }
        break;
   /*   case 'onAckPause':
        if (onAckPause != null) {
          map.remove("event");
          onAckPause!(map);
        }
        break;
      case 'onAckResume':
        if (onAckResume != null) {
          map.remove("event");
          onAckResume!(map);
        }
        break;
      case 'onAckMuteRoom':
        if (onAckMuteRoom != null) {
          map.remove("event");
          onAckMuteRoom!(map);
        }
        break;
      case 'onAckUnmuteRoom':
        if (onAckUnmuteRoom != null) {
          map.remove("event");
          onAckUnmuteRoom!(map);
        }
        break;*/
      case 'onFailedJoinBreakOutRoom':
        if (onFailedJoinBreakOutRoom != null) {
          map.remove("event");
          onFailedJoinBreakOutRoom!(map);
        }
        break;
      case 'onConnectedBreakoutRoom':
        if (onConnectedBreakoutRoom != null) {
          map.remove("event");
          onConnectedBreakoutRoom!(map);
        }
        break;
      case 'onDisconnectedBreakoutRoom':
        if (onDisconnectedBreakoutRoom != null) {
          map.remove("event");
          onDisconnectedBreakoutRoom!(map);
        }
        break;
      case 'onUserJoinedBreakoutRoom':
        if (onUserJoinedBreakoutRoom != null) {
          map.remove("event");
          onUserJoinedBreakoutRoom!(map);
        }
        break;
      case 'onInvitationForBreakoutRoom':
        if (onInvitationForBreakoutRoom != null) {
          map.remove("event");
          onInvitationForBreakoutRoom!(map);
        }
        break;
      case 'onDestroyedBreakoutRoom':
        if (onDestroyedBreakoutRoom != null) {
          map.remove("event");
          onDestroyedBreakoutRoom!(map);
        }
        break;
      case 'onUserDisconnectedFromBreakoutRoom':
        if (onUserDisconnectedFromBreakoutRoom != null) {
          map.remove("event");
          onUserDisconnectedFromBreakoutRoom!(map);
        }
        break;
      case 'onAckRejectBreakOutRoom':
        if (onAckRejectBreakOutRoom != null) {
          map.remove("event");
          onAckRejectBreakOutRoom!(map);
        }
        break;
      case 'onBreakoutRoomCreated':
        if (onBreakoutRoomCreated != null) {
          map.remove("event");
          onBreakoutRoomCreated!(map);
        }
        break;
      case 'onBreakoutRoomInvited':
        if (onBreakoutRoomInvited != null) {
          map.remove("event");
          onBreakoutRoomInvited!(map);
        }
        break;
      case 'onBreakoutRoomInviteRejected':
        if (onBreakoutRoomInviteRejected != null) {
          map.remove("event");
          onBreakoutRoomInviteRejected!(map);
        }
        break;

      case 'onAckAddSpotlightUsers':
        if (onAckAddSpotlightUsers != null) {
          map.remove("event");
          onAckAddSpotlightUsers!(map);
        }
        break;
      case 'onAckRemoveSpotlightUsers':
        if (onAckRemoveSpotlightUsers != null) {
          map.remove("event");
          onAckRemoveSpotlightUsers!(map);
        }
        break;
      case 'onUpdateSpotlightUsers':
        if (onUpdateSpotlightUsers != null) {
          map.remove("event");
          onUpdateSpotlightUsers!(map);
        }
        break;
      case 'onAckSwitchedRoom':
        if (onAckSwitchedRoom != null) {
          map.remove("event");
          onAckSwitchedRoom!(map);
        }
        break;
      case 'onRoomModeSwitched':
        if (onRoomModeSwitched != null) {
          map.remove("event");
          onRoomModeSwitched!(map);
        }
        break;
      case 'onAckStartStreaming':
        if (onAckStartStreaming != null) {
          map.remove("event");
          onAckStartStreaming!(map);
        }
        break;
      case 'onAckStopStreaming':
        if (onAckStopStreaming != null) {
          map.remove("event");
          onAckStopStreaming!(map);
        }
        break;
      case 'onStreamingStarted':
        if (onStreamingStarted != null) {
          map.remove("event");
          onStreamingStarted!(map);
        }
        break;
      case 'onStreamingStopped':
        if (onStreamingStopped != null) {
          map.remove("event");
          onStreamingStopped!(map);
        }
        break;
      case 'onStreamingFailed':
        if (onStreamingFailed != null) {
          map.remove("event");
          onStreamingFailed!(map);
        }
        break;
      case 'onStreamingUpdated':
        if (onStreamingUpdated != null) {
          map.remove("event");
          onStreamingUpdated!(map);
        }
        break;


        case 'onACKStartLiveRecording':
        if (onACKStartLiveRecording != null) {
          map.remove("event");
          onACKStartLiveRecording!(map);
        }
        break;
        case 'onACKStopLiveRecording':
        if (onACKStopLiveRecording != null) {
          map.remove("event");
          onACKStopLiveRecording!(map);
        }
        break;
        case 'onRoomLiveRecordingOn':
        if (onRoomLiveRecordingOn != null) {
          map.remove("event");
          onRoomLiveRecordingOn!(map);
        }
        break;
        case 'onRoomLiveRecordingOff':
        if (onRoomLiveRecordingOff != null) {
          map.remove("event");
          onRoomLiveRecordingOff!(map);
        }
        break;
      case 'onRoomLiveRecordingFailed':
        if (onRoomLiveRecordingFailed != null) {
          map.remove("event");
          onRoomLiveRecordingFailed!(map);
        }
        break;
      case 'onRoomLiveRecordingUpdate':
        if (onRoomLiveRecordingUpdate != null) {
          map.remove("event");
          onRoomLiveRecordingUpdate!(map);
        }
        break;



      case 'onAckHardMuteUserAudio':
        if (onAckHardMuteUserAudio != null) {
          map.remove("event");
          onAckHardMuteUserAudio!(map);
        }
        break;
      case 'onAckHardunMuteUserAudio':
        if (onAckHardunMuteUserAudio != null) {
          map.remove("event");
          onAckHardunMuteUserAudio!(map);
        }
        break;
      case 'onAckHardMuteUserVideo':
        if (onAckHardMuteUserVideo != null) {
          map.remove("event");
          onAckHardMuteUserVideo!(map);
        }
        break;
      case 'onAckHardUnMuteUserVideo':
        if (onAckHardUnMuteUserVideo != null) {
          map.remove("event");
          onAckHardUnMuteUserVideo!(map);
        }
        break;

      case 'onAnnotationStarted':
        if (onAnnotationStarted != null) {
          map.remove("event");
          onAnnotationStarted!(map);
        }
        break;
      case 'onAnnotationStopped':
        if (onAnnotationStopped != null) {
          map.remove("event");
          onAnnotationStopped!(map);
        }
        break;
      case 'onStartAnnotationAck':
        if (onStartAnnotationAck != null) {
          map.remove("event");
          onStartAnnotationAck!(map);
        }
        break;
      case 'onStoppedAnnotationAck':
        if (onStoppedAnnotationAck != null) {
          map.remove("event");
          onStoppedAnnotationAck!(map);
        }
        break;
      case 'onACKStartLiveTranscription':
        if (onACKStartLiveTranscription != null) {
          map.remove("event");
          onACKStartLiveTranscription!(map);
        }
        break;
      case 'onACKStopLiveTranscription':
        if (onACKStopLiveTranscription != null) {
          map.remove("event");
          onACKStopLiveTranscription!(map);
        }
        break;
      case 'onTranscriptionEvents':
        if (onTranscriptionEvents != null) {
          map.remove("event");
          onTranscriptionEvents!(map);
        }
        break;
      case 'onRoomTranscriptionOn':
        if (onRoomTranscriptionOn != null) {
          map.remove("event");
          onRoomTranscriptionOn!(map);
        }
        break;
      case 'onRoomTranscriptionOff':
        if (onRoomTranscriptionOff != null) {
          map.remove("event");
          onRoomTranscriptionOff!(map);
        }
        break;
      case 'onSelfTranscriptionOn':
        if (onSelfTranscriptionOn != null) {
          map.remove("event");
          onSelfTranscriptionOn!(map);
        }
        break;
      case 'onSelfTranscriptionOff':
        if (onSelfTranscriptionOff != null) {
          map.remove("event");
          onSelfTranscriptionOff!(map);
        }
        break;
      case 'onHlsStarted':
        if (onHlsStarted != null) {
          map.remove("event");
          onHlsStarted!(map);
        }
        break;
      case 'onHlsStopped':
        if (onHlsStopped != null) {
          map.remove("event");
          onHlsStopped!(map);
        }
        break;
      case 'onHlsFailed':
        if (onHlsFailed != null) {
          map.remove("event");
          onHlsFailed!(map);
        }
        break;
      case 'onHlsWaiting':
        if (onHlsWaiting != null) {
          map.remove("event");
          onHlsWaiting!(map);
        }
        break;
    }
  }
}
