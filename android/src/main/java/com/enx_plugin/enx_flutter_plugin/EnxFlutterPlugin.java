package com.enx_plugin.enx_flutter_plugin;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

import enx_rtc_android.Controller.EnxActiveTalkerListObserver;
import enx_rtc_android.Controller.EnxAdvancedOptionsObserver;
import enx_rtc_android.Controller.EnxAnnotationObserver;
import enx_rtc_android.Controller.EnxBandwidthObserver;
import enx_rtc_android.Controller.EnxBreakoutRoomObserver;
import enx_rtc_android.Controller.EnxCanvasObserver;
import enx_rtc_android.Controller.EnxChairControlObserver;
import enx_rtc_android.Controller.EnxFileShareObserver;
import enx_rtc_android.Controller.EnxHlsStreamObserver;
import enx_rtc_android.Controller.EnxLiveStreamingObserver;
import enx_rtc_android.Controller.EnxLockRoomManagementObserver;
import enx_rtc_android.Controller.EnxLogsObserver;
import enx_rtc_android.Controller.EnxMuteAudioStreamObserver;
import enx_rtc_android.Controller.EnxMuteRoomObserver;
import enx_rtc_android.Controller.EnxMuteVideoStreamObserver;
import enx_rtc_android.Controller.EnxNetworkObserever;
import enx_rtc_android.Controller.EnxOutBoundCallObserver;
import enx_rtc_android.Controller.EnxPlayerView;
import enx_rtc_android.Controller.EnxReconnectObserver;
import enx_rtc_android.Controller.EnxRecordingObserver;
import enx_rtc_android.Controller.EnxRoom;
import enx_rtc_android.Controller.EnxRoomMuteUserObserver;
import enx_rtc_android.Controller.EnxRoomObserver;
import enx_rtc_android.Controller.EnxRtc;
import enx_rtc_android.Controller.EnxScreenShareObserver;
import enx_rtc_android.Controller.EnxScreenShotObserver;
import enx_rtc_android.Controller.EnxStatsObserver;
import enx_rtc_android.Controller.EnxStream;
import enx_rtc_android.Controller.EnxStreamObserver;
import enx_rtc_android.Controller.EnxSwitchRoomObserver;
import enx_rtc_android.Controller.EnxTalkerNotificationObserver;
import enx_rtc_android.Controller.EnxTalkerObserver;
import enx_rtc_android.Controller.EnxTranscriptionObserver;
import enx_rtc_android.Controller.EnxTroubleShooterObserver;
import enx_rtc_android.Controller.EnxUtilityManager;
import enx_rtc_android.Controller.EnxLiveRecordingObserver;
import enx_rtc_android.annotations.EnxAnnotationsToolbar;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMessageCodec;

/**
 * EnxFlutterPlugin
 */
public class EnxFlutterPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    //
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    /**
     * The EventChannel used to pass observer callbacks to flutter plugin
     */
    private EventChannel eventChannel;
    private Handler mEventHandler = new Handler(Looper.getMainLooper());
    private EventChannel.EventSink sink;
    private EnxRtc enxRtc;
    private EnxStream localStream;
    private EnxStream screenShareStream,annotationStream;
    private EnxStream canvasStream;
    private HashMap<String, FrameLayout> mRendererViews;
    private EnxRoom mEnxRoom;
    public Activity mActivity;

    /**
     * map for handling remote streams
     */
    private ConcurrentHashMap<String, EnxStream> mRemoteStream = new ConcurrentHashMap<>();

    /**
     * map for handling activetalker streams
     */
    private ConcurrentHashMap<String, EnxStream> mActiveStreams = new ConcurrentHashMap<>();

    void addView(FrameLayout view, int id) {
        mRendererViews.put("" + id, view);
        System.out.println("addviewid show in print " + id + mRendererViews);
    }


    public ConcurrentHashMap<String, EnxStream> getRemoteStream() {

        return this.mRemoteStream;
    }

    public ConcurrentHashMap<String, EnxStream> getActiveStream() {

        return this.mActiveStreams;
    }

    private void removeView(int id) {
        if (mRendererViews != null)
            System.out.println("renderview id when removing printing" + mRendererViews + id);
        mRendererViews.remove("" + id);
    }

    FrameLayout getView(int id) {
     //   System.out.println("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwrenderview id printing" + mRendererViews + id);
        return mRendererViews.get("" + id);
    }

    /**
     * Plugin registration.
     */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "enx_flutter_plugin");
        eventChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "enx_flutter_plugin_event_channel");
        this.sink = null;
        this.mRendererViews = new HashMap<>();
        channel.setMethodCallHandler(this);
        eventChannel.setStreamHandler(this);
        EnxPlayerViewFactory fac = new EnxPlayerViewFactory(StandardMessageCodec.INSTANCE,
                this);

        EnxToolbarViewFactory toolbar = new EnxToolbarViewFactory(StandardMessageCodec.INSTANCE,
                this);

        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("EnxToolbarView",toolbar);

        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("EnxPlayer", fac);
    }

    /**
     * used for taking methods and parameters from flutter Plugin
     */
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.d("onMethodCall", call.method);
        String clientId = "";
        int viewId = -1;
        int vId=-1;
        int uid = -1;
        boolean isLocal = false;
        if (call.hasArgument("clientId")) {
            clientId = call.argument("clientId");
        }
        if (call.hasArgument("viewId")) {
            viewId = call.argument("viewId");
        }
        if (call.hasArgument("vId")) {
            vId = call.argument("vId");
        }

        if (call.hasArgument("uid")) {
            uid = call.argument("uid");
        }
        if (call.hasArgument("isLocal")) {
            isLocal = call.argument("isLocal");
        }
        switch (call.method) {
            case "joinRoom":
                String token = call.argument("token");
                HashMap<String, Object> localInfo;
                HashMap<String, Object> roomInfo;
                ArrayList<Object> advanceOptions;

                JSONObject localInfoObject = null;
                JSONObject roomInfoObject = null;
                JSONArray advanceOptionsObject = null;
                try {
                    if (call.argument("localInfo") != null) {
                        localInfo = call.argument("localInfo");
                        localInfoObject = EnxUtils.convertMapToJson(localInfo);
                    }
                    if (call.argument("roomInfo") != null) {
                        roomInfo = call.argument("roomInfo");
                        roomInfoObject = EnxUtils.convertMapToJson(roomInfo);
                    }
                    if (call.argument("advanceOptions") != null) {
                        advanceOptions = call.argument("advanceOptions");
                        advanceOptionsObject = getAdvancedOptionsObject(advanceOptions);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                enxRtc = new EnxRtc(mActivity, mRoomObserver, mStreamObserver, mEnxAdvanceOptionObserver, mScreenShotObserver);
                localStream = enxRtc.joinRoom(token, localInfoObject, roomInfoObject, advanceOptionsObject);
                if (localStream != null) {
                    localStream.setMuteAudioStreamObserver(mEnxMuteAudioStreamObserver);
                    localStream.setMuteVideoStreamObserver(mEnxMuteVideoStreamObserver);
                }
//                if(enxRtc!=null){
//
//                    enxRtc = new EnxRtc(mActivity, mRoomObserver, mStreamObserver, mEnxAdvanceOptionObserver, mScreenShotObserver);
//                    localStream = enxRtc.joinRoom(token, localInfoObject, roomInfoObject, advanceOptionsObject);
//                    if (localStream != null) {
//                        localStream.setMuteAudioStreamObserver(mEnxMuteAudioStreamObserver);
//                        localStream.setMuteVideoStreamObserver(mEnxMuteVideoStreamObserver);
//                    }
//                }else {
//                   new Handler().postDelayed(new Runnable() {
//                       @Override
//                       public void run() {
//                           if (call.argument("localInfo") != null) {
//                               HashMap<String,Object> localInfo;
//                               localInfo = call.argument("localInfo");
//                               try {
//                                 JSONObject  localInfoObject = EnxUtils.convertMapToJson(localInfo);
//                                 enxRtc = new EnxRtc(mActivity, mRoomObserver, mStreamObserver, mEnxAdvanceOptionObserver, mScreenShotObserver);
//                                 localStream = enxRtc.joinRoom(token, localInfoObject, null, null);
//                               } catch (JSONException e) {
//                                   e.printStackTrace();
//                               }
//                           }
//                           if (localStream != null) {
//                               localStream.setMuteAudioStreamObserver(mEnxMuteAudioStreamObserver);
//                               localStream.setMuteVideoStreamObserver(mEnxMuteVideoStreamObserver);
//                           }
//                       }
//                   },3000);
//                }
                result.success(null);
                break;
            case "removeNativeView":
                removeView(viewId);
                result.success(null);
                break;

            case "publish":
                if (mEnxRoom != null) {
                    mEnxRoom.publish(localStream);
                }
                result.success(null);
                break;

            case "disconnect":
                if (mEnxRoom != null) {
                    mEnxRoom.disconnect();
                }
                result.success(null);
                break;
            case "startRecord":
                if (mEnxRoom != null) {
                    mEnxRoom.startRecord();
                }
                result.success(null);
                break;
            case "stopRecord":
                if (mEnxRoom != null) {
                    mEnxRoom.stopRecord();
                }
                result.success(null);
                break;
            case "setTalkerCount":
                int count = call.argument("count");
                if (mEnxRoom != null) {
                    mEnxRoom.setTalkerCount(count);
                }
                result.success(null);
                break;
            case "getTalkerCount":
                if (mEnxRoom != null) {
                    mEnxRoom.getTalkerCount();
                }
                result.success(null);
                break;
            case "getMaxTalkers":
                if (mEnxRoom != null) {
                    mEnxRoom.getMaxTalkers();
                }
                result.success(null);
                break;
            case "enableLogs":
                boolean status = call.argument("status");
                EnxUtilityManager enxLogsUtil = EnxUtilityManager.getInstance();
                enxLogsUtil.enableLogs(status);
                result.success(null);
                break;
            case "postClientLogs":
                if (mEnxRoom != null) {
                    mEnxRoom.postClientLogs();
                }
                result.success(null);
                break;
            case "requestFloor":
                if (mEnxRoom != null) {
                    mEnxRoom.requestFloor();
                }
                result.success(null);
                break;
            case "grantFloor":
                if (mEnxRoom != null) {
                    mEnxRoom.grantFloor(clientId);
                }
                result.success(null);
                break;
            case "cancelFloor":
                if (mEnxRoom != null) {
                    mEnxRoom.cancelFloor();
                }
                result.success(null);
                break;
            case "finishFloor":
                if (mEnxRoom != null) {
                    mEnxRoom.finishFloor();
                }
                result.success(null);
                break;
            case "denyFloor":
                if (mEnxRoom != null) {
                    mEnxRoom.denyFloor(clientId);
                }
                result.success(null);
                break;
            case "releaseFloor":
                if (mEnxRoom != null) {
                    mEnxRoom.releaseFloor(clientId);
                }
                result.success(null);
                break;
            //
            case "inviteToFloor":
                String inviteClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    mEnxRoom.inviteToFloor(inviteClientId);
                }
                result.success(null);
                break;
            case "cancelFloorInvite":
                String cancelClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    mEnxRoom.cancelFloorInvite(cancelClientId);
                }
                result.success(null);
                break;
            case "rejectInviteFloor":
                String rejectClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    mEnxRoom.rejectInviteFloor(rejectClientId);
                }
                result.success(null);
                break;
            case "acceptInviteFloorRequest":
                String acceptClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    mEnxRoom.acceptInviteFloorRequest(acceptClientId);
                }
                result.success(null);
                break;
            //

            case "hardMute":
                if (mEnxRoom != null) {
                    mEnxRoom.hardMute();
                }
                result.success(null);
                break;
            case "hardUnMute":
                if (mEnxRoom != null) {
                    mEnxRoom.hardUnMute();
                }
                result.success(null);
                break;
            case "muteSelfAudio":
                boolean isMuteAudio = call.argument("isMute");
                if (mEnxRoom != null) {
                    localStream.muteSelfAudio(isMuteAudio);
                }
                result.success(null);
                break;
            case "muteSelfVideo":
                boolean isMuteVideo = call.argument("isMute");
                if (mEnxRoom != null) {
                    localStream.muteSelfVideo(isMuteVideo);
                }
                result.success(null);
                break;

            case "enableProximitySensor":
                boolean isEnabled = call.argument("isEnabled");
                if (mEnxRoom != null) {
                    mEnxRoom.enableProximitySensor(isEnabled);
                }
                result.success(null);
                break;
            case "hardMuteAudio":
                String muteClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    localStream.hardMuteAudio(muteClientId);
                }
                result.success(null);
                break;
            case "hardUnMuteAudio":
                String unMuteClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    localStream.hardUnMuteAudio(unMuteClientId);
                }
                result.success(null);
                break;
            case "hardMuteVideo":
                String muteVideoClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    localStream.hardMuteVideo(muteVideoClientId);
                }
                result.success(null);
                break;
            case "hardUnMuteVideo":
                String unMuteVideoClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    localStream.hardUnMuteVideo(unMuteVideoClientId);
                }
                result.success(null);
                break;
            case "switchCamera":
                if (localStream != null) {
                    localStream.switchCamera();
                }
                result.success(null);
                break;
            case "getAdvancedOptions":
                if (mEnxRoom != null) {
                    mEnxRoom.getAdvancedOptions();
                }
                result.success(null);
                break;
            case "sendData":
                if (mEnxRoom != null) {
                    String data = call.argument("data");
                    JSONObject dataObject = null;
                    try {
                        if (data != null) {
                            dataObject = new JSONObject(data);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    localStream.sendData(dataObject);
                }
                result.success(null);
                break;
            case "lockRoom":
                if (mEnxRoom != null) {
                    mEnxRoom.lockRoom();
                }
                result.success(null);
                break;
            case "unLockRoom":
                if (mEnxRoom != null) {
                    mEnxRoom.unLockRoom();
                }
                result.success(null);
                break;
            case "makeOutboundCall":
                String number = call.argument("number");
                String callerId = call.argument("callerId");
                if (mEnxRoom != null) {
                    mEnxRoom.makeOutboundCall(number, callerId);
                }
                result.success(null);
                break;
            case "makeOutboundCallWithDialerOption":
                String pnumber = call.argument("number");
                String callerID = call.argument("callerId");
                HashMap<String, Object> dialOptions;
                JSONObject dialOptionsObject = null;

                if (call.argument("dialOptions") != null) {
                    dialOptions = call.argument("dialOptions");
                    try {
                        dialOptionsObject = EnxUtils.convertMapToJson(dialOptions);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                if (mEnxRoom != null) {
                    mEnxRoom.makeOutboundCall(pnumber, callerID,dialOptionsObject);
                }
                result.success(null);
                break;
            case "makeOutboundCallWithMultipleUser":
                String calleriD = call.argument("callerId");
                HashMap<String, Object> dialOptions1;
                JSONObject dialOptionsObject1 = null;
                ArrayList<String> numberlist = (ArrayList<String>) call.argument("number");


                if (call.argument("dialOptions") != null) {
                    dialOptions1 = call.argument("dialOptions");
                    try {
                        dialOptionsObject1 = EnxUtils.convertMapToJson(dialOptions1);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                if (mEnxRoom != null) {
                    mEnxRoom.makeOutboundCalls(numberlist, calleriD,dialOptionsObject1);
                }
                result.success(null);
                break;

            case "cancelOutboundCall":
                String phoneNumber = call.argument("number");
                if (mEnxRoom != null) {
                    mEnxRoom.cancelOutboundCall(phoneNumber);
                }
                result.success(null);
                break;

            case "extendConferenceDuration":
                if (mEnxRoom != null) {
                    mEnxRoom.extendConferenceDuration();
                }
                result.success(null);
                break;
            case "destroy":
                if (mEnxRoom != null) {
                    mEnxRoom.destroy();
                }
                result.success(null);
                break;
            case "stopVideoTracksOnApplicationBackground":
                boolean videoMuteLocalStream = call.argument("videoMuteLocalStream");
                boolean videoMuteRemoteStream = call.argument("videoMuteRemoteStream");
                if (mEnxRoom != null) {
                    mEnxRoom.stopVideoTracksOnApplicationBackground(videoMuteRemoteStream, videoMuteLocalStream);
                }
                result.success(null);
                break;
            case "startVideoTracksOnApplicationForeground":
                boolean restoreVideoRemoteStream = call.argument("restoreVideoRemoteStream");
                boolean restoreVideoLocalStream = call.argument("restoreVideoLocalStream");
                if (mEnxRoom != null) {
                    mEnxRoom.startVideoTracksOnApplicationForeground(restoreVideoRemoteStream, restoreVideoLocalStream);
                }
                result.success(null);
                break;
            case "setAudioOnlyMode":
                boolean audioOnly = call.argument("audioOnly");
                if (mEnxRoom != null) {
                    mEnxRoom.setAudioOnlyMode(audioOnly);
                }
                result.success(null);
                break;
            case "switchMediaDevice":
                String deviceName = call.argument("deviceName");
                if (mEnxRoom != null) {
                    mEnxRoom.switchMediaDevice(deviceName);
                }
                result.success(null);
                break;
            case "switchUserRole":
                if (mEnxRoom != null) {
                    mEnxRoom.switchUserRole(clientId);
                }
                result.success(null);
                break;
            case "getAvailableFiles":
                if (mEnxRoom != null) {
                    try {
                        if (mEnxRoom.getAvailableFiles() != null) {
                            result.success(EnxUtils.jsonToMap(mEnxRoom.getAvailableFiles()));
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            case "getDevices":
                if (mEnxRoom != null) {
                    try {
                        if (mEnxRoom.getDevices() != null) {
                            result.success(mEnxRoom.getDevices());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                break;
            case "enableStats":
                boolean enableStats = call.argument("enableStats");
                if (mEnxRoom != null) {
                    mEnxRoom.enableStats(enableStats, mEnxStatsObserver);
                }
                result.success(null);
                break;
            case "muteSubscribeStreamsAudio":
                boolean isMute = call.argument("isMute");
                if (mEnxRoom != null) {
                    mEnxRoom.muteSubscribeStreamsAudio(isMute);
                }
                result.success(null);
                break;
            case "getRoomId":
                if (mEnxRoom != null) {
                    if (mEnxRoom.getRoomId() != null) {
                        result.success(mEnxRoom.getRoomId());
                    }
                }
                break;
            case "getClientName":
                if (mEnxRoom != null) {
                    if (mEnxRoom.getClientId() != null) {
                        result.success(mEnxRoom.getClientName());
                    }
                }
                break;
            case "getClientId":
                if (mEnxRoom != null) {
                    if (mEnxRoom.getClientId() != null) {
                        result.success(mEnxRoom.getClientId());
                    }
                }
                break;
            case "getRole":
                if (mEnxRoom != null) {
                    if (mEnxRoom.getRole() != null) {
                        result.success(mEnxRoom.getRole());
                    }
                }
                break;
            case "isRoomActiveTalker":
                if (mEnxRoom != null) {
                    result.success(mEnxRoom.isRoomActiveTalker());
                }
                break;
            case "cancelDownload":
                int jobId = call.argument("jobId");
                if (mEnxRoom != null) {
                    mEnxRoom.cancelDownload(jobId);
                }
                result.success(null);
                break;
            case "cancelUpload":
                int upJobId = call.argument("jobId");
                if (mEnxRoom != null) {
                    mEnxRoom.cancelUpload(upJobId);
                }
                result.success(null);
                break;
            case "cancelAllDownloads":
                if (mEnxRoom != null) {
                    mEnxRoom.cancelAllDownloads();
                }
                result.success(null);
                break;
            case "cancelAllUploads":
                if (mEnxRoom != null) {
                    mEnxRoom.cancelAllUploads();
                }
                result.success(null);
                break;
            case "downloadFile":
                boolean isAutoSave = call.argument("autoSave");
                HashMap<String, Object> fileInfo;
                JSONObject fileInfoObject = null;
                try {
                    if (call.argument("file") != null) {
                        fileInfo = call.argument("file");
                        fileInfoObject = EnxUtils.convertMapToJson(fileInfo);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (mEnxRoom != null) {
                    mEnxRoom.downloadFile(fileInfoObject, isAutoSave);
                }
                result.success(null);
                break;
            case "updateConfiguration":
                HashMap<String, Object> configInfo;
                JSONObject configObject = null;
                try {
                    if (call.argument("config") != null) {
                        configInfo = call.argument("config");
                        configObject = EnxUtils.convertMapToJson(configInfo);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (localStream != null) {
                    localStream.updateConfiguration(configObject);
                }
                result.success(null);
                break;
            case "getSelectedDevice":
                if (mEnxRoom != null) {
                    if (mEnxRoom.getSelectedDevice() != null) {
                        result.success(mEnxRoom.getSelectedDevice());
                    }
                }
                break;
            case "sendUserData":
                JSONObject messageObject = null;
                HashMap<String, Object> messageMap;
                boolean isBroadCast = call.argument("isBroadCast");
                ArrayList<String> list = (ArrayList<String>) call.argument("recipientIDs");
                try {
                    if (call.argument("message") != null) {
                        messageMap = call.argument("message");
                        messageObject = EnxUtils.convertMapToJson(messageMap);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (mEnxRoom != null) {
                    mEnxRoom.sendUserData(messageObject, isBroadCast, list);
                }
                result.success(null);
                break;
            case "sendMessage":
                String message = call.argument("message");
                boolean broadCast = call.argument("isBroadCast");
                ArrayList<String> recipientIDs = (ArrayList<String>) call.argument("recipientIDs");
                if (mEnxRoom != null) {
                    mEnxRoom.sendMessage(message, broadCast, recipientIDs);
                }
                result.success(null);
                break;
            case "sendFiles":
                boolean broadCastStatus = call.argument("isBroadCast");
                ArrayList<String> clientList = (ArrayList<String>) call.argument("recipientIDs");
                if (mEnxRoom != null) {
                    mEnxRoom.sendFiles(broadCastStatus, clientList, mActivity);
                }
                result.success(null);
                break;
            case "getUserList":
                try {
                    result.success(EnxUtils.toList(mEnxRoom.getUserList()));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "whoAmI":
                if (mEnxRoom != null) {
                    try {
                        result.success(EnxUtils.jsonToMap(mEnxRoom.whoAmI()));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                break;
            case "setupVideo":
                if (isLocal) {
                  //  System.out.println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxsetup video local viewid:" + String.valueOf(viewId) + "uid" + String.valueOf(uid));
                    if(localStream == null){
                        return;
                    }

                    if(localStream.mEnxPlayerView == null)
                    {
                        return;
                    }
                    try{
                        FrameLayout frameLayout = (FrameLayout) getView(viewId).getParent();

                        if (frameLayout != null) {
                            getView(viewId).removeAllViews();
                        }

                        localStream.mEnxPlayerView.setZOrderMediaOverlay(true);

                        getView(viewId).addView(localStream.mEnxPlayerView);

                    }catch(Exception e){
                    }



                } else {
                    ConcurrentHashMap<String, EnxStream> remoteStream = getActiveStream();
//                    if(getActiveStream().size()>0){
                 //   System.out.println("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyysetup video remote stream" + remoteStream);
                    Log.e("activeViewId:" + String.valueOf(viewId), "uid" + String.valueOf(uid));
                    if (getView(viewId) != null && remoteStream.get(String.valueOf(uid)) != null) {

                        FrameLayout frameLayout = (FrameLayout) remoteStream.get(String.valueOf(uid)).mEnxPlayerView.getParent();
                        if (frameLayout != null) {
                            frameLayout.removeAllViewsInLayout();
                            frameLayout.invalidate();
                        }
                        getView(viewId).addView(remoteStream.get(String.valueOf(uid)).mEnxPlayerView);

                     //   System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsetupvideo viewid and uid" + viewId + uid);

                    }
                    else{
                        if(screenShareStream != null){
                            FrameLayout frameLayout = (FrameLayout) getView(viewId).getParent();
                            if (frameLayout != null) {
                                getView(viewId).removeAllViews();
                            }
                            getView(viewId).addView(screenShareStream.mEnxPlayerView);
                        }
                        else if(canvasStream != null){
                            FrameLayout frameLayout = (FrameLayout) getView(viewId).getParent();
                            if (frameLayout != null) {
                                getView(viewId).removeAllViews();
                            }
                            getView(viewId).addView(canvasStream.mEnxPlayerView);
                        }
                       else if(annotationStream != null){
                            FrameLayout frameLayout = (FrameLayout) getView(viewId).getParent();
                            if (frameLayout != null) {
                                getView(viewId).removeAllViews();
                            }
                            getView(viewId).addView(annotationStream.mEnxPlayerView);
                        }

                    }
                }
                break;
            case "getReceiveVideoQuality":
                String streamType = call.argument("streamType");
                if (mEnxRoom != null) {
                    result.success(mEnxRoom.getReceiveVideoQuality(streamType));
                }
                break;
            case "dropUser":
                ArrayList<String> clientIds = (ArrayList<String>) call.argument("clientIds");
                if (mEnxRoom != null) {
                    mEnxRoom.dropUser(clientIds);
                }
                result.success(null);
                break;
            case "setAdvancedOptions":
                JSONArray array = call.argument("advanceOptions");
                if (mEnxRoom != null) {
                    mEnxRoom.setAdvancedOptions(array, mEnxAdvanceOptionObserver);
                }
                break;
            case "subscribe":
                String streamId = call.argument("streamId");
                ConcurrentHashMap<String, EnxStream> mSubscriberStreams = getRemoteStream();
                if (mEnxRoom != null) {
                    mEnxRoom.subscribe(mSubscriberStreams.get(streamId));
                }
                result.success(null);
                break;
            case "setPlayerScalingType":
                String type = call.argument("type");
                EnxPlayerView.ScalingType scalingType = EnxPlayerView.ScalingType.SCALE_ASPECT_BALANCED;
                if (type.equalsIgnoreCase("SCALE_ASPECT_BALANCED")) {
                    scalingType = EnxPlayerView.ScalingType.SCALE_ASPECT_BALANCED;
                } else if (type.equalsIgnoreCase("SCALE_ASPECT_FIT")) {
                    scalingType = EnxPlayerView.ScalingType.SCALE_ASPECT_FIT;
                } else if (type.equalsIgnoreCase("SCALE_ASPECT_FILL")) {
                    scalingType = EnxPlayerView.ScalingType.SCALE_ASPECT_FILL;
                }
                if (isLocal) {
                    if (localStream != null) {
//                        mRendererViews.get("0").setScalingType(scalingType);
//                        localStream.attachRenderer(mRendererViews.get("0"));
                    }
                } else {
                    ConcurrentHashMap<String, EnxStream> remoteStream = getRemoteStream();
                    if (remoteStream != null && remoteStream.size() > 0) {
//                        mRendererViews.get(String.valueOf(viewId)).setScalingType(scalingType);
//                        remoteStream.get(String.valueOf(uid)).attachRenderer(mRendererViews.get(String.valueOf(viewId)));
                    }
                }
                break;
            case "setZOrderMediaOverlay":
                boolean mediaOverlay = call.argument("mediaOverlay");
                if (isLocal) {
                    if (localStream != null) {
                        localStream.mEnxPlayerView.setZOrderMediaOverlay(mediaOverlay);
//                        mRendererViews.get("0").setZOrderMediaOverlay(mediaOverlay);
                    }
                } else {
                    ConcurrentHashMap<String, EnxStream> remoteStream = getRemoteStream();
                    if (remoteStream != null && remoteStream.size() > 0) {
//                        mRendererViews.get(String.valueOf(viewId)).setZOrderMediaOverlay(mediaOverlay);
                    }
                }

                break;
            case "captureScreenShot":
                String screenstreamId = call.argument("streamId");
                ConcurrentHashMap<String, EnxStream> mCaptureScreenShot = getRemoteStream();
                assert screenstreamId != null;
                if (isLocal) {
                   // System.out.println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxsetup video local viewid:" + String.valueOf(viewId) + "uid" + String.valueOf(uid));
                    if (localStream != null) {
                        localStream.mEnxPlayerView.captureScreenShot(mScreenShotObserver);
                    }
                }
                else  {
                    if(  !mCaptureScreenShot.contains(screenstreamId)){
                        if (localStream != null) {
                            localStream.mEnxPlayerView.captureScreenShot(mScreenShotObserver);
                        }
                    }
                    else {
                        if (mCaptureScreenShot.get(screenstreamId).mEnxPlayerView != null)
                            mCaptureScreenShot.get(screenstreamId).mEnxPlayerView.captureScreenShot(mScreenShotObserver);
                    }
                }
                break;
            case "startScreenShare":
                if (mEnxRoom != null) {
                    mEnxRoom.startScreenShare();
                }
                result.success(null);
                break;
            case "stopScreenShare":
                if (mEnxRoom != null) {
                    mEnxRoom.stopScreenShare();
                }
                result.success(null);
                break;

            case "pinUsers":
                ArrayList<String> userList = (ArrayList<String>) call.argument("userList");
                if (mEnxRoom != null) {
                    mEnxRoom.pinUsers(userList);
                }
                result.success(null);
                break;
            case "unpinUsers":
                ArrayList<String> unPinUserList = (ArrayList<String>) call.argument("userList");
                if (mEnxRoom != null) {
                    mEnxRoom.unpinUsers(unPinUserList);
                }
                result.success(null);
                break;
            case "createBreakOutRoom":
                JSONObject createBreakOutInfoObject = null;
                HashMap<String, Object> createBreakOutRoomInfo;
                try {
                    if (call.argument("createBreakoutInfo") != null) {
                        createBreakOutRoomInfo = call.argument("createBreakoutInfo");
                        createBreakOutInfoObject = EnxUtils.convertMapToJson(createBreakOutRoomInfo);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (mEnxRoom != null) {
                    mEnxRoom.createBreakOutRoom(createBreakOutInfoObject);
                }
                result.success(null);

                break;

            case "createAndInviteBreakoutRoom":
                JSONObject createInviteBreakOutInfoObject = null;
                HashMap<String, Object> creatInviteBreakOutRoomInfo;
                try {
                    if (call.argument("createandInviteBreakOutInfo") != null) {
                        creatInviteBreakOutRoomInfo = call.argument("createandInviteBreakOutInfo");
                        createInviteBreakOutInfoObject = EnxUtils.convertMapToJson(creatInviteBreakOutRoomInfo);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (mEnxRoom != null) {
                    mEnxRoom.createAndInviteBreakoutRoom(createInviteBreakOutInfoObject);
                }
                result.success(null);
                break;
            case "joinBreakOutRoom":

                HashMap<String, Object> dataInfo;
                HashMap<String, Object> streamInfo;

                JSONObject dataInfoObject = null;
                JSONObject streamInfoObject = null;
                try {
                    if (call.argument("dataInfo") != null) {
                        dataInfo = call.argument("dataInfo");
                        dataInfoObject = EnxUtils.convertMapToJson(dataInfo);
                    }
                    if (call.argument("streamInfo") != null) {
                        streamInfo = call.argument("streamInfo");
                        streamInfoObject = EnxUtils.convertMapToJson(streamInfo);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (mEnxRoom != null) {
                    mEnxRoom.joinBreakOutRoom(dataInfoObject,streamInfoObject);
                }
                result.success(null);

                break;
            case "inviteToBreakOutRoom":
                JSONObject inviteBreakOutInfoObject = null;
                HashMap<String, Object> inviteBreakOutRoomInfo;
                try {
                    if (call.argument("inviteBreakOutInfo") != null) {
                        inviteBreakOutRoomInfo = call.argument("inviteBreakOutInfo");
                        inviteBreakOutInfoObject = EnxUtils.convertMapToJson(inviteBreakOutRoomInfo);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (mEnxRoom != null) {
                    mEnxRoom.inviteToBreakOutRoom(inviteBreakOutInfoObject);
                }
                result.success(null);
            case "pause":
                if (mEnxRoom != null) {
                    mEnxRoom.pause();
                }
                result.success(null);
                break;
            case "resume":
                if (mEnxRoom != null) {
                    mEnxRoom.resume();
                }
                result.success(null);
                break;
            case "muteRoom":
                JSONObject muteRoomObject = null;
                HashMap<String, Object> muteRoomInfo;
                try {
                    if (call.argument("muteRoomInfo") != null) {
                        muteRoomInfo = call.argument("muteRoomInfo");
                        muteRoomObject = EnxUtils.convertMapToJson(muteRoomInfo);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (mEnxRoom != null) {
                    try {
                        mEnxRoom.muteRoom(muteRoomObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                result.success(null);
                break;
            case "unmuteRoom":
                JSONObject unMuteRoomObject = null;
                HashMap<String, Object> unMuteRoomInfo;
                try {
                    if (call.argument("unMuteRoomInfo") != null) {
                        unMuteRoomInfo = call.argument("unMuteRoomInfo");
                        unMuteRoomObject = EnxUtils.convertMapToJson(unMuteRoomInfo);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (mEnxRoom != null) {
                    try {
                        mEnxRoom.unmuteRoom(unMuteRoomObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                result.success(null);
                break;

            case "rejectBreakOutRoom":
                String breakoutRoomId = call.argument("breakoutRoomId");
                if (mEnxRoom != null) {
                    mEnxRoom.rejectBreakOutRoom(breakoutRoomId);
                }
                result.success(null);
            case "clientDiagnostics":
                JSONObject optionsObject = null;
                HashMap<String, Object> optionInfo;
                try {
                    if (call.argument("optionInfo") != null) {
                        optionInfo = call.argument("optionInfo");
                        assert optionInfo != null;
                        optionsObject = EnxUtils.convertMapToJson(optionInfo);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                enxRtc = new EnxRtc(mActivity);
                enxRtc.setEnxTroubleShooterObserver(mEnxTroubleShooterObserver);

                if (enxRtc != null) {
                    enxRtc.clientDiagnostics(optionsObject);
                }
                result.success(null);
                break;
            case "subscribeForTalkerNotification":
                boolean isTalkerNotification = call.argument("isTalkerNotification");
                if (mEnxRoom != null) {
                    mEnxRoom.subscribeForTalkerNotification(isTalkerNotification,enxTalkerNotificationObserver);
                }
                result.success(null);
                break;


            case "approveAwaitedUser":
                String awaitClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    mEnxRoom.approveAwaitedUser(awaitClientId);
                }
                result.success(null);
                break;
            case "denyAwaitedUser":
                String denyClientId = call.argument("clientId");
                if (mEnxRoom != null) {
                    mEnxRoom.denyAwaitedUser(denyClientId);
                }
                result.success(null);
                break;

            case "addSpotlightUsers":
                ArrayList<String> addSpotLightuserList = (ArrayList<String>) call.argument("userList");
                if (mEnxRoom != null) {
                    mEnxRoom.addSpotlightUsers(addSpotLightuserList);
                }
                result.success(null);
                break;
            case "removeSpotlightUsers":
                ArrayList<String> removeSpotUserList = (ArrayList<String>) call.argument("userList");
                if (mEnxRoom != null) {
                    mEnxRoom.removeSpotlightUsers(removeSpotUserList);
                }
                result.success(null);
                break;
            case "switchRoomMode":
                String mode = call.argument("roomMode");
                if (mEnxRoom != null) {
                    mEnxRoom.switchRoomMode(mode);
                }
                result.success(null);
                break;

            case "startStreaming":
                JSONObject streamingDetailsObject = null;
                HashMap<String, Object> streamingDetails;
                try {
                    if (call.argument("streamingDetails") != null) {
                        streamingDetails = call.argument("streamingDetails");
                        assert streamingDetails != null;
                        streamingDetailsObject = EnxUtils.convertMapToJson(streamingDetails);
                        if (mEnxRoom != null) {
                            mEnxRoom.startStreaming(streamingDetailsObject);
                        }
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                result.success(null);
                break;
            case "stopStreaming":
                JSONObject stopStreamingObject = null;
                HashMap<String, Object> stopStreamingInfo;
                try {
                    if (call.argument("streamingDetails") != null) {
                        stopStreamingInfo = call.argument("streamingDetails");
                        assert stopStreamingInfo != null;
                        stopStreamingObject = EnxUtils.convertMapToJson(stopStreamingInfo);
                        if (mEnxRoom != null) {
                            mEnxRoom.stopStreaming(stopStreamingObject);
                        }
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                result.success(null);
                break;
            case "startLiveRecording":
                JSONObject liveRecordingDetailsObject = null;
                HashMap<String, Object> liveRecordingDetails;
                try {
                    if (call.argument("streamingDetails") != null) {
                        liveRecordingDetails = call.argument("streamingDetails");
                        assert liveRecordingDetails != null;
                        liveRecordingDetailsObject = EnxUtils.convertMapToJson(liveRecordingDetails);
                        if (mEnxRoom != null) {
                            mEnxRoom.startLiveRecording(liveRecordingDetailsObject);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                result.success(null);
                break;
            case "stopLiveRecording":
                if (mEnxRoom != null) {
                    mEnxRoom.stopLiveRecording();
                }
                result.success(null);
                break;
            case "hardMuteUserAudio":
                String harMuteClientId = call.argument("clientId");

                if (mEnxRoom != null) {
                    mEnxRoom.hardMuteUserAudio(harMuteClientId);
                }
                result.success(null);
                break;

            case "hardUnmuteUserAudio":
                String hardUnMuteClientId = call.argument("clientId");

                if (mEnxRoom != null) {
                    mEnxRoom.hardUnmuteUserAudio(hardUnMuteClientId);
                }
                result.success(null);
                break;
            case "hardMuteUserVideo":
                String hardVideoClientId = call.argument("clientId");

                if (mEnxRoom != null) {
                    mEnxRoom.hardMuteUserVideo(hardVideoClientId);
                }
                result.success(null);
                break;
            case "hardUnmuteUserVideo":
                String hardUnClientId = call.argument("clientId");

                if (mEnxRoom != null) {
                    mEnxRoom.hardUnmuteUserVideo(hardUnClientId);
                }
                result.success(null);
                break;
            case "highlightBorderForClient":
                ArrayList<String> borderClientId = (ArrayList<String>) call.argument("clientId");

                if (mEnxRoom != null) {
                    mEnxRoom.highlightBorderForClient(borderClientId);
                }
                result.success(null);
                break;
            case "changeBgColorForClients":
                ArrayList<String> bgClientId = (ArrayList<String>) call.argument("clientId");
                String color=call.argument("clientId");

                if (mEnxRoom != null) {
                    mEnxRoom.changeBgColorForClients(bgClientId,color);
                }
                result.success(null);
                break;


            case "startAnnotation":
                String annotationStreamId = call.argument("streamId");
                ConcurrentHashMap<String, EnxStream> mAnnotation = getRemoteStream();
                assert annotationStreamId != null;
                if (mEnxRoom != null) {

                if (mAnnotation.get(annotationStreamId) != null)
                    mEnxRoom.startAnnotation(mAnnotation.get(annotationStreamId));
                }
                result.success(null);
                break;
            case "stopAnnotation":
                if (mEnxRoom != null) {
                    mEnxRoom.stopAnnotations();
                }
                result.success(null);
                break;

            case "setupToolbar":

                try{
                    FrameLayout frameLayout = (FrameLayout) getView(vId).getParent();

                    if (frameLayout != null) {
                        getView(vId).removeAllViews();
                    }


                }catch(Exception e){
                }


                break;

            case "startLiveTranscription":
                String language = call.argument("language");

                if (mEnxRoom != null) {
                    mEnxRoom.startLiveTranscription(language);
                }
                result.success(null);

                break;
            case "startLiveTranscriptionForRoom":
                String languag = call.argument("language");

                if (mEnxRoom != null) {
                    mEnxRoom.startLiveTranscriptionForRoom(languag);
                }
                result.success(null);

                break;

            case "stopLiveTranscription":
                if (mEnxRoom != null) {
                    mEnxRoom.stopLiveTranscription();
                }
                result.success(null);

                break;



            default:
                result.notImplemented();
        }
    }

    /**
     * Plugin removed.
     */
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.sink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.sink = null;
    }

    /**
     * called when activty binding done
     */
    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        Log.d("onAttachedToActivity", "Plugin");
//        enxRtc = new EnxRtc(binding.getActivity(), mRoomObserver, mStreamObserver, mEnxAdvanceOptionObserver, mScreenShotObserver);
        mActivity = binding.getActivity();
    }

    /**
     * called when configuration changed for the activity
     */
    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d("onDetachedFromActivity", "Plugin");
    }

    /**
     * called when activity again attached after configuration changes
     */
    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        Log.d("onReattachedToActivity", "Plugin");
    }

    /**
     * called when activity detached
     */
    @Override
    public void onDetachedFromActivity() {
        Log.d("onDetachedFromActivity", "Plugin");
    }

    /**
     * listobserver for adding the active talker streams
     */
    private final EnxActiveTalkerListObserver mListObserver = new EnxActiveTalkerListObserver() {
        @Override
        public void onActiveTalkerList(List<EnxStream> list) {
            System.out.println("activetalkerListxxxxxxxxxxxxxxxxxxxx" + list.size());
            getActiveStream().clear();
            if (list.size() == 0) {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("activeList", new JSONArray());
                    sendEvent("onActiveTalkerList", EnxUtils.jsonToMap(jsonObject));
                } catch (JSONException exception) {
                    exception.printStackTrace();
                }
                return;
            }
            ConcurrentHashMap<String, EnxStream> mSubscriberStreams = getActiveStream();
            for (int i = 0; i < list.size(); i++) {
                mSubscriberStreams.put(list.get(i).getId(), list.get(i));
            }

            JSONObject jsonObject = new JSONObject();
            JSONArray jsonArray = new JSONArray();
            try {
                for (int i = 0; i < list.size(); i++) {

                    EnxStream enxStream = list.get(i);

                    JSONObject object = new JSONObject();
                    object.put("clientId", enxStream.getClientId());
                    object.put("name", enxStream.getName());
                    object.put("mediatype", enxStream.getMediaType());
                    object.put("videoaspectratio", enxStream.getVideoAspectRatio());
                    object.put("streamId", enxStream.getId());
                    object.put("pinned", enxStream.isPinned());
                    object.put("videomuted", enxStream.isVideoActive());

                    jsonArray.put(object);
                }
                jsonObject.put("activeList", jsonArray);
                System.out.println("newCOdejsonObjxxxxxxxxxxxxxxx" + jsonObject);
                sendEvent("onActiveTalkerList", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }


//
            for (int i = 1; i < list.size(); i++) {
                if (getView(i) == null) {
                    return;
                }
               if (getView(i).getChildCount() > 0) {
                    getView(i).removeAllViewsInLayout();
                }
                getView(i).addView(list.get(i - 1).mEnxPlayerView);

              /*  ViewGroup r = ((ViewGroup) list.get(i - 1).mEnxPlayerView.getParent());
               if(r==null){
                    getView(i).addView(list.get(i - 1).mEnxPlayerView);
                }else{
                    FrameLayout layout = (FrameLayout) r;
                    layout.removeView(list.get(i - 1).mEnxPlayerView);
                    getView(i).addView(list.get(i - 1).mEnxPlayerView);
                }*/
            }

        }
    };

    /**
     * EnxRoomObserver for sending the room callbacks events
     */
    private final EnxRoomObserver mRoomObserver = new EnxRoomObserver() {
        @Override
        public void onRoomConnected(EnxRoom enxRoom, JSONObject jsonObject) {
            mEnxRoom = enxRoom;
            try {
                sendEvent("onRoomConnected", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
            mEnxRoom.setRecordingObserver(mRecordingObserver);
            mEnxRoom.setTalkerObserver(mEnxTalkerObserver);
            mEnxRoom.setLogsObserver(mEnxLogsObserver);
            mEnxRoom.setBandwidthObserver(mEnxBandwidthObserver);
            mEnxRoom.setNetworkChangeObserver(mEnxNetworkObserver);
            mEnxRoom.setChairControlObserver(mEnxChairControlObserver);
            mEnxRoom.setMuteRoomObserver(mEnxMuteRoomObserver);
            mEnxRoom.setLockRoomManagementObserver(mLockRoomObserver);
            mEnxRoom.setOutBoundCallObserver(mEnxOutBoundCallObserver);
            mEnxRoom.setReconnectObserver(mEnxReconnectObserver);
            mEnxRoom.setScreenShareObserver(mEnxScreenShareObserver);
            mEnxRoom.setCanvasObserver(mEnxCanvasObserver);
            mEnxRoom.setFileShareObserver(mEnxFileShareObserver);
//            mEnxRoom.setActiveTalkerViewObserver(mViewObserver);
            mEnxRoom.setActiveTalkerListObserver(mListObserver);
            mEnxRoom.setBreakoutRoomObserver(enxBreakOutRoomObserver);
            mEnxRoom.setEnxSwitchRoomObserver(enxSwitchRoomObserver);
            mEnxRoom.setLiveStreamingObserver(enxLiveStreamingObserver);
            mEnxRoom.setLiveRecordingObserver(enxLiveRecordingObserver);
            mEnxRoom.setEnxRoomMuteUserObserver(enxRoomMuteUserObserver);
            mEnxRoom.setAnnotationObserver(enxAnnotationObserver);
            mEnxRoom.setmEnxTranscriptionObserver(enxTranscriptionObserver);
            mEnxRoom.setEnxHlsObserver(enxHlsObserver);
        }

        @Override
        public void onRoomError(JSONObject jsonObject) {
            try {
                sendEvent("onRoomError", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserConnected(JSONObject jsonObject) {
            try {
                sendEvent("onUserConnected", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserDisConnected(JSONObject jsonObject) {
            try {
                sendEvent("onUserDisConnected", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onPublishedStream(EnxStream enxStream) {
            HashMap<String, String> map = new HashMap<>();
            map.put("result", "0");
            map.put("msg", "The stream has been published.");
            if (localStream != null) {
                map.put("streamId", mEnxRoom.getLocalStreamID());
            }
//            if (localStream != null) {
//                getView(0).addView(localStream.mEnxPlayerView);
//            }
            sendEvent("onPublishedStream", map);

        }

        @Override
        public void onUnPublishedStream(EnxStream enxStream) {

        }

        @Override
        public void onStreamAdded(EnxStream enxStream) {

            ConcurrentHashMap<String, EnxStream> mSubscriberStreams = getRemoteStream();
            mSubscriberStreams.put(enxStream.getId(), enxStream);
            HashMap<String, Object> map = new HashMap<>();
            map.put("streamId", enxStream.getId());
            map.put("hasScreen", enxStream.hasScreen());
            map.put("hasData", enxStream.hasData());
            sendEvent("onStreamAdded", map);

            System.out.println("show subcribe stream length " + mSubscriberStreams.size());
        }

        @Override
        public void onSubscribedStream(EnxStream enxStream) {
//            ConcurrentHashMap<String, EnxStream> mSubscriberStreams = enxState.getRemoteStream();
//            mSubscriberStreams.put(enxStream.getId(), enxStream);
            HashMap<String, Object> map = new HashMap<>();
            map.put("result", "0");
            map.put("streamId", enxStream.getId());
            map.put("msg", "Stream subscribed successfully.");
            sendEvent("onSubscribedStream", map);
        }

        @Override
        public void onUnSubscribedStream(EnxStream enxStream) {

        }

        @Override
        public void onRoomDisConnected(JSONObject jsonObject) {
            try {
                sendEvent("onRoomDisConnected", EnxUtils.jsonToMap(jsonObject));
                releaseAllResources();
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


        @Override
        public void onEventError(JSONObject jsonObject) {
            try {
                sendEvent("onEventError", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onEventInfo(JSONObject jsonObject) {
            try {
                sendEvent("onEventInfo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onNotifyDeviceUpdate(String s) {
            try {
                HashMap<String, Object> map = new HashMap<>();
                map.put("msg", s);
                sendEvent("onNotifyDeviceUpdate", map);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAcknowledgedSendData(JSONObject jsonObject) {
            try {
                sendEvent("onAcknowledgedSendData", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onMessageReceived(JSONObject jsonObject) {
            try {
                sendEvent("onMessageReceived", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserDataReceived(JSONObject jsonObject) {
            try {
                sendEvent("onUserDataReceived", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onSwitchedUserRole(JSONObject jsonObject) {
            try {
                sendEvent("onSwitchedUserRole", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserRoleChanged(JSONObject jsonObject) {
            try {
                sendEvent("onUserRoleChanged", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onConferencessExtended(JSONObject jsonObject) {
            try {
                sendEvent("onConferencessExtended", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onConferenceRemainingDuration(JSONObject jsonObject) {
            try {
                sendEvent("onConferenceRemainingDuration", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckDropUser(JSONObject jsonObject) {
            try {
                sendEvent("onAckDropUser", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckDestroy(JSONObject jsonObject) {
            try {
                sendEvent("onAckDestroy", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckPinUsers(JSONObject jsonObject) {
            try {
                sendEvent("onAckPinUsers", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckUnpinUsers(JSONObject jsonObject) {
            try {
                sendEvent("onAckUnpinUsers", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onPinnedUsers(JSONObject jsonObject) {
            try {
                sendEvent("onPinnedUsers", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomAwaited(EnxRoom enxRoom, JSONObject jsonObject) {

            try {
                sendEvent("onRoomAwaited", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserAwaited(JSONObject jsonObject){
            try {
                sendEvent("onUserAwaited", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckForApproveAwaitedUser(JSONObject jsonObject){
            try {
                sendEvent("onAckForApproveAwaitedUser", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        @Override
        public void onAckForDenyAwaitedUser(JSONObject jsonObject){
            try {
                sendEvent("onAckForDenyAwaitedUser", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


        //new api
        @Override
        public void onAckAddSpotlightUsers(JSONObject jsonObject) {
            try {
                sendEvent("onAckAddSpotlightUsers", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckRemoveSpotlightUsers(JSONObject jsonObject) {
            try {
                sendEvent("onAckRemoveSpotlightUsers", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUpdateSpotlightUsers(JSONObject jsonObject) {
            try {
                sendEvent("onUpdateSpotlightUsers", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomBandwidthAlert(JSONObject jsonObject) {
            try {
                sendEvent("onRoomBandwidthAlert", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStopAllSharingACK(JSONObject jsonObject) {
            try {
                sendEvent("onStopAllSharingACK", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }



        @Override
        public void onUserStartTyping(boolean b) {
            // Handel
        }
    };

    /*EnxScreenShotObserver for sending the screenshots callback event*/
    private final EnxScreenShotObserver mScreenShotObserver = new EnxScreenShotObserver() {
        @Override
        public void OnCapturedView(Bitmap bitmap) {
            try {
                HashMap<String, Object> map = new HashMap<>();
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
                byte[] byteArray = byteArrayOutputStream .toByteArray();
                String encoded = Base64.encodeToString(byteArray, Base64.DEFAULT);
                map.put("bitmap", encoded);
                sendEvent("OnCapturedView", map);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxStreamObserver for sending the stream callbacks events
     */
    private final EnxStreamObserver mStreamObserver = new EnxStreamObserver() {
        @Override
        public void onAudioEvent(JSONObject jsonObject) {
            try {
                sendEvent("onAudioEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onVideoEvent(JSONObject jsonObject) {
            try {
                sendEvent("onVideoEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedData(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedData", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRemoteStreamAudioMute(JSONObject jsonObject) {
            try {
                sendEvent("onRemoteStreamAudioMute", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRemoteStreamAudioUnMute(JSONObject jsonObject) {
            try {
                sendEvent("onRemoteStreamAudioUnMute", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRemoteStreamVideoMute(JSONObject jsonObject) {
            try {
                sendEvent("onRemoteStreamVideoMute", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRemoteStreamVideoUnMute(JSONObject jsonObject) {
            try {
                sendEvent("onRemoteStreamVideoUnMute", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxRecordingObserver for sending the recording callbacks events
     */
    private final EnxRecordingObserver mRecordingObserver = new EnxRecordingObserver() {
        @Override
        public void onStartRecordingEvent(JSONObject jsonObject) {
            try {
                sendEvent("onStartRecordingEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomRecordingOn(JSONObject jsonObject) {
            try {
                sendEvent("onRoomRecordingOn", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStopRecordingEvent(JSONObject jsonObject) {
            try {
                sendEvent("onStopRecordingEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomRecordingOff(JSONObject jsonObject) {
            try {
                sendEvent("onRoomRecordingOff", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxTalkerObserver for sending the talker callbacks events
     */
    private final EnxTalkerObserver mEnxTalkerObserver = new EnxTalkerObserver() {
        @Override
        public void onSetTalkerCount(JSONObject jsonObject) {
            try {
                sendEvent("onSetTalkerCount", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onGetTalkerCount(JSONObject jsonObject) {
            try {
                sendEvent("onGetTalkerCount", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onMaxTalkerCount(JSONObject jsonObject) {
            try {
                sendEvent("onMaxTalkerCount", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxLogsObserver for sending the logs callbacks events
     */
    private final EnxLogsObserver mEnxLogsObserver = new EnxLogsObserver() {
        @Override
        public void onLogUploaded(JSONObject jsonObject) {
            try {
                sendEvent("onLogUploaded", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxAdvancedOptionsObserver for sending advanced options callbacks events
     */
    private final EnxAdvancedOptionsObserver mEnxAdvanceOptionObserver = new EnxAdvancedOptionsObserver() {
        @Override
        public void onAdvancedOptionsUpdate(JSONObject jsonObject) {
            try {
                sendEvent("onAdvancedOptionsUpdate", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onGetAdvancedOptions(JSONObject jsonObject) {
            try {
                sendEvent("onGetAdvancedOptions", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxBandwidthObserver for sending bandwidth callbacks events
     */
    private final EnxBandwidthObserver mEnxBandwidthObserver = new EnxBandwidthObserver() {
        @Override
        public void onBandWidthUpdated(JSONArray jsonArray) {
            try {
                HashMap<String, Object> map = new HashMap<>();
                map.put("bandwidth", EnxUtils.toList(jsonArray));
                sendEvent("onBandWidthUpdated", map);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onShareStreamEvent(JSONObject jsonObject) {
            try {
                sendEvent("onShareStreamEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onCanvasStreamEvent(JSONObject jsonObject) {
            try {
                sendEvent("onCanvasStreamEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxNetworkObserever for sending network callbacks events
     */
    private final EnxNetworkObserever mEnxNetworkObserver = new EnxNetworkObserever() {
        @Override
        public void onConnectionInterrupted(JSONObject jsonObject) {
            try {
                sendEvent("onConnectionInterrupted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onConnectionLost(JSONObject jsonObject) {
            try {
                sendEvent("onConnectionLost", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxChairControlObserver for sending chaircontrol callbacks events
     */
    private final EnxChairControlObserver mEnxChairControlObserver = new EnxChairControlObserver() {
        @Override
        public void onFloorRequested(JSONObject jsonObject) {
            try {
                sendEvent("onFloorRequested", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFloorRequestReceived(JSONObject jsonObject) {
            try {
                sendEvent("onFloorRequestReceived", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onProcessFloorRequested(JSONObject jsonObject) {
            try {
                sendEvent("onProcessFloorRequested", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onGrantedFloorRequest(JSONObject jsonObject) {
            try {
                sendEvent("onGrantedFloorRequest", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onDeniedFloorRequest(JSONObject jsonObject) {
            try {
                sendEvent("onDeniedFloorRequest", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReleasedFloorRequest(JSONObject jsonObject) {
            try {
                sendEvent("onReleasedFloorRequest", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFloorCancelled(JSONObject jsonObject) {
            try {
                sendEvent("onFloorCancelled", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFloorFinished(JSONObject jsonObject) {
            try {
                sendEvent("onFloorFinished", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onCancelledFloorRequest(JSONObject jsonObject) {
            try {
                sendEvent("onCancelledFloorRequest", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFinishedFloorRequest(JSONObject jsonObject) {
            try {
                sendEvent("onFinishedFloorRequest", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


        //new
        @Override
        public void onACKInviteToFloorRequested(JSONObject jsonObject) {
            try {
                sendEvent("onACKInviteToFloorRequested", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onInviteToFloorRequested(JSONObject jsonObject) {
            try {
                sendEvent("onInviteToFloorRequested", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onInvitedForFloorAccess(JSONObject jsonObject) {
            try {
                sendEvent("onInvitedForFloorAccess", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onCanceledFloorInvite(JSONObject jsonObject) {
            try {
                sendEvent("onCanceledFloorInvite", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRejectedInviteFloor(JSONObject jsonObject) {
            try {
                sendEvent("onRejectedInviteFloor", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAcceptedFloorInvite(JSONObject jsonObject) {
            try {
                sendEvent("onAcceptedFloorInvite", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxMuteRoomObserver for sending mute/unmute callbacks events
     */
    private final EnxMuteRoomObserver mEnxMuteRoomObserver = new EnxMuteRoomObserver() {
        @Override
        public void onHardMuted(JSONObject jsonObject) {
            try {
                sendEvent("onHardMuted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedHardMute(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedHardMute", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onHardUnMuted(JSONObject jsonObject) {
            try {
                sendEvent("onHardUnMuted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedHardUnMute(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedHardUnMute", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxLockRoomManagementObserver for sending lock/unlock callbacks events
     */
    private final EnxLockRoomManagementObserver mLockRoomObserver = new EnxLockRoomManagementObserver() {
        @Override
        public void onAckLockRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckLockRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckUnLockRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckUnLockRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onLockedRoom(JSONObject jsonObject) {
            try {
                sendEvent("onLockedRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUnLockedRoom(JSONObject jsonObject) {
            try {
                sendEvent("onUnLockedRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxOutBoundCallObserver for sending outbound calls callbacks events
     */
    private final EnxOutBoundCallObserver mEnxOutBoundCallObserver = new EnxOutBoundCallObserver() {
        @Override
        public void onOutBoundCallInitiated(JSONObject jsonObject) {
            try {
                sendEvent("onOutBoundCallInitiated", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onDialStateEvents(EnxRoom.EnxOutBoundCallState enxOutBoundCallState) {
            try {
                HashMap<String, Object> map = new HashMap<>();
                map.put("state", enxOutBoundCallState.toString());
                sendEvent("onDialStateEvents", map);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onDTMFCollected(String s) {
            try {
                HashMap<String, Object> map = new HashMap<>();
                map.put("msg", s);
                sendEvent("onDTMFCollected", map);
            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onOutBoundCallCancel(JSONObject jsonObject) {
            try {
                sendEvent("onOutBoundCallCancel", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
        @Override
        public void onDialStateEvents(JSONObject jsonObject) {
            try {
                sendEvent("onDialStateEvent", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }        }

       /* @Override
        public void onDTMFCollected(JSONObject jsonObject) {
            try {
                sendEvent("onDTMFCollecteds", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }        }*/
    };

    /**
     * EnxMuteAudioStreamObserver for sending mute/ummute audiostream  callbacks events
     */
    private final EnxMuteAudioStreamObserver mEnxMuteAudioStreamObserver = new EnxMuteAudioStreamObserver() {
        @Override
        public void onHardMutedAudio(JSONObject jsonObject) {
            try {
                sendEvent("onHardMutedAudio", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onHardUnMutedAudio(JSONObject jsonObject) {
            try {
                sendEvent("onHardUnMutedAudio", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedHardMuteAudio(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedHardMuteAudio", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedHardUnMuteAudio(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedHardUnMuteAudio", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxMuteVideoStreamObserver for sending mute/ummute videostream  callbacks events
     */
    private final EnxMuteVideoStreamObserver mEnxMuteVideoStreamObserver = new EnxMuteVideoStreamObserver() {
        @Override
        public void onHardMutedVideo(JSONObject jsonObject) {
            try {
                sendEvent("onHardMutedVideo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onHardUnMutedVideo(JSONObject jsonObject) {
            try {
                sendEvent("onHardUnMutedVideo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedHardMuteVideo(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedHardMuteVideo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedHardUnMuteVideo(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedHardUnMuteVideo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxReconnectObserver for sending reconnect callbacks events
     */
    private final EnxReconnectObserver mEnxReconnectObserver = new EnxReconnectObserver() {
        @Override
        public void onReconnect(String s) {
            try {
                HashMap<String, Object> map = new HashMap<>();
                map.put("msg", s);
                sendEvent("onReconnect", map);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserReconnectSuccess(EnxRoom enxRoom, JSONObject jsonObject) {
            try {
                sendEvent("onUserReconnectSuccess", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxScreenShareObserver for sending screenshare callbacks events
     */
    private final EnxScreenShareObserver mEnxScreenShareObserver = new EnxScreenShareObserver() {


        @Override
        public void onScreenSharedStarted(EnxStream enxStream) {
            try {
                screenShareStream = enxStream;
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("name", enxStream.getName());
                jsonObject.put("clientId", enxStream.getClientId());
                jsonObject.put("streamId", enxStream.getId());
                sendEvent("onScreenSharedStarted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onScreenSharedStopped(EnxStream enxStream) {
            try {
                screenShareStream = null;
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("name", enxStream.getName());
                jsonObject.put("clientId", enxStream.getClientId());
                jsonObject.put("streamId", enxStream.getId());

                sendEvent("onScreenSharedStopped", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStartScreenShareACK(JSONObject jsonObject) {
            try {
                sendEvent("onStartScreenShareACK", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStoppedScreenShareACK(JSONObject jsonObject) {
            try {
                sendEvent("onStoppedScreenShareACK", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

    };

    /**
     * EnxCanvasObserver for sending canvas callbacks events
     */
    private final EnxCanvasObserver mEnxCanvasObserver = new EnxCanvasObserver() {

        @Override
        public void onCanvasStarted(EnxStream enxStream) {
            try {
                canvasStream =  enxStream;
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("name", enxStream.getName());
                jsonObject.put("clientId", enxStream.getClientId());
                jsonObject.put("streamId", enxStream.getId());

                sendEvent("onCanvasStarted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


        @Override
        public void onCanvasStopped(EnxStream enxStream) {
            try {
                canvasStream =  null;
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("name", enxStream.getName());
                jsonObject.put("clientId", enxStream.getClientId());
                jsonObject.put("streamId", enxStream.getId());

                sendEvent("onCanvasStopped", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStartCanvasAck(JSONObject jsonObject) {
            try {
                sendEvent("onStartCanvasAck", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStoppedCanvasAck(JSONObject jsonObject) {
            try {
                sendEvent("onStoppedCanvasAck", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxFileShareObserver for sending fileshare callbacks events
     */
    private final EnxFileShareObserver mEnxFileShareObserver = new EnxFileShareObserver() {
        @Override
        public void onFileUploadStarted(JSONObject jsonObject) {
            try {
                sendEvent("onFileUploadStarted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileAvailable(JSONObject jsonObject) {
            try {
                sendEvent("onFileAvailable", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onInitFileUpload(JSONObject jsonObject) {
            try {
                sendEvent("onInitFileUpload", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileUploaded(JSONObject jsonObject) {
            try {
                sendEvent("onFileUploaded", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileUploadCancelled(JSONObject jsonObject) {
            try {
                sendEvent("onFileUploadCancelled", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileUploadFailed(JSONObject jsonObject) {
            try {
                sendEvent("onFileUploadFailed", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileDownloaded(JSONObject jsonObject) {
            try {
                sendEvent("onFileDownloaded", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileDownloadCancelled(JSONObject jsonObject) {
            try {
                sendEvent("onFileDownloadCancelled", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onFileDownloadFailed(JSONObject jsonObject) {
            try {
                sendEvent("onFileDownloadFailed", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onInitFileDownload(JSONObject jsonObject) {
            try {
                sendEvent("onInitFileDownload", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /**
     * EnxStatsObserver for sending stats callbacks events
     */
    private final EnxStatsObserver mEnxStatsObserver = new EnxStatsObserver() {
        @Override
        public void onAcknowledgeStats(JSONObject jsonObject) {
            try {
                sendEvent("onAcknowledgeStats", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedStats(JSONObject jsonObject) {
            try {
                sendEvent("onReceivedStats", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /*EnxTalkerNotificationObserver for sending subscribe,unsubscribe and talkernotification  callbacks events*/
    private final EnxTalkerNotificationObserver enxTalkerNotificationObserver=new EnxTalkerNotificationObserver(){
        @Override
        public void onAckSubscribeTalkerNotification(JSONObject jsonObject) {
            try {
                sendEvent("onAckSubscribeTalkerNotification", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onAckUnsubscribeTalkerNotification(JSONObject jsonObject) {
            try {
                sendEvent("onAckUnsubscribeTalkerNotification", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onTalkerNtification(JSONObject jsonObject) {
            try {
                sendEvent("onTalkerNtification", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /*EnxTroubleShooterObserver for sending client DiagnosisFailed,DiagnosisStop,DiagnosisFinished,DiagnosisDtop*/
    private  final EnxTroubleShooterObserver mEnxTroubleShooterObserver=new EnxTroubleShooterObserver(){


        @Override
        public void onClientDiagnosisFailed(JSONObject jsonObject) {
            try {
                sendEvent("onClientDiagnosisFailed", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onClientDiagnosisStopped(JSONObject jsonObject) {
            try {
                sendEvent("onClientDiagnosisStopped", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onClientDiagnosisFinished(JSONObject jsonObject) {
            try {
                sendEvent("onClientDiagnosisFinished", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onClientDiagnosisStatus(JSONObject jsonObject) {
            try {
                sendEvent("onClientDiagnosisStatus", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };
    /*EnxBreakoutRoomObserver  for sending breakout room callback events*/
    private final EnxBreakoutRoomObserver enxBreakOutRoomObserver=new EnxBreakoutRoomObserver(){
        @Override
        public void onAckCreateBreakOutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckCreateBreakOutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckCreateAndInviteBreakOutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckCreateAndInviteBreakOutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckInviteBreakOutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckInviteBreakOutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }



        @Override
        public void onFailedJoinBreakOutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onFailedJoinBreakOutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onConnectedBreakoutRoom(EnxRoom breakoutRoom, JSONObject jsonObject) {
            try {
                sendEvent("onConnectedBreakoutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onDisconnectedBreakoutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onDisconnectedBreakoutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserJoinedBreakoutRoom(EnxRoom enxRoom, JSONObject jsonObject) {
            try {
                sendEvent("onUserJoinedBreakoutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


        @Override
        public void onInvitationForBreakoutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onInvitationForBreakoutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onDestroyedBreakoutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onDestroyedBreakoutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onUserDisconnectedFromBreakoutRoom(EnxRoom enxRoom, JSONObject jsonObject) {
            try {
                sendEvent("onUserDisconnectedFromBreakoutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        //new
        @Override
        public void onAckRejectBreakOutRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckRejectBreakOutRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        @Override
        public void onBreakoutRoomCreated(JSONObject jsonObject) {
            try {
                sendEvent("onBreakoutRoomCreated", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        @Override
        public void onBreakoutRoomInvited(JSONObject jsonObject) {
            try {
                sendEvent("onBreakoutRoomInvited", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        @Override
        public void onBreakoutRoomInviteRejected(JSONObject jsonObject) {
            try {
                sendEvent("onBreakoutRoomInviteRejected", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onBreakoutroomjoining(JSONObject jsonObject) {

        }
    };

    /*EnxSwitchRoomObserver  for sending switch room callback events*/
    private final EnxSwitchRoomObserver enxSwitchRoomObserver=new EnxSwitchRoomObserver(){

        @Override
        public void onAckSwitchedRoom(JSONObject jsonObject) {
            try {
                sendEvent("onAckSwitchedRoom", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomModeSwitched(JSONObject jsonObject) {
            try {
                sendEvent("onRoomModeSwitched", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    /*EnxLiveStreamingRoomObserver  for sending switch room callback events*/
    private final EnxLiveStreamingObserver enxLiveStreamingObserver=new EnxLiveStreamingObserver(){

        @Override
        public void onAckStartStreaming(JSONObject jsonObject) {
            try {
                sendEvent("onAckStartStreaming", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckStopStreaming(JSONObject jsonObject) {
            try {
                sendEvent("onAckStopStreaming", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStreamingStarted(JSONObject jsonObject) {
            try {
                sendEvent("onStreamingStarted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStreamingStopped(JSONObject jsonObject) {
            try {
                sendEvent("onStreamingStopped", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStreamingFailed(JSONObject jsonObject) {
            try {
                sendEvent("onStreamingFailed", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onStreamingUpdated(JSONObject jsonObject) {
            try {
                sendEvent("onStreamingUpdated", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


    };
    /*EnxLiveRecordingRommObserver  for sending live Recording room callback events*/
    private final EnxLiveRecordingObserver enxLiveRecordingObserver=new EnxLiveRecordingObserver(){

        @Override
        public void onACKStartLiveRecording(JSONObject jsonObject) {
            try {
                sendEvent("onACKStartLiveRecording", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onACKStopLiveRecording(JSONObject jsonObject) {
            try {
                sendEvent("onACKStopLiveRecording", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomLiveRecordingOn(JSONObject jsonObject) {
            try {
                sendEvent("onRoomLiveRecordingOn", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomLiveRecordingOff(JSONObject jsonObject) {
            try {
                sendEvent("onRoomLiveRecordingOff", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomLiveRecordingFailed(JSONObject jsonObject) {
            try {
                sendEvent("onRoomLiveRecordingFailed", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomLiveRecordingUpdate(JSONObject jsonObject) {
            try {
                sendEvent("onRoomLiveRecordingUpdate", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }


    };


    /*    EnxRoomMuteUserObserver  */

    private  final EnxRoomMuteUserObserver enxRoomMuteUserObserver= new EnxRoomMuteUserObserver() {
        @Override
        public void onAckHardMuteUserAudio(JSONObject jsonObject) {
            try {
                sendEvent("onAckHardMuteUserAudio", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onAckHardunMuteUserAudio(JSONObject jsonObject) {
            try {
                sendEvent("onAckHardunMuteUserAudio", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckHardMuteUserVideo(JSONObject jsonObject) {
            try {
                sendEvent("onAckHardMuteUserVideo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onAckHardUnMuteUserVideo(JSONObject jsonObject) {
            try {
                sendEvent("onAckHardUnMuteUserVideo", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };


    /*EnxAnnotationObserver*/

    private  final EnxAnnotationObserver enxAnnotationObserver=new EnxAnnotationObserver() {
        @Override
        public void onAnnotationStarted(EnxStream enxStream) {
            try {
                annotationStream = enxStream;
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("name", enxStream.getName());
                jsonObject.put("clientId", enxStream.getClientId());
                jsonObject.put("streamId", enxStream.getId());
                sendEvent("onAnnotationStarted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onStartAnnotationAck(JSONObject jsonObject) {
            try {
                sendEvent("onStartAnnotationAck", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onAnnotationStopped(EnxStream enxStream) {
            try {
                annotationStream = null;
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("result", 0);
                jsonObject.put("name", enxStream.getName());
                jsonObject.put("clientId", enxStream.getClientId());
                jsonObject.put("streamId", enxStream.getId());

                sendEvent("onAnnotationStopped", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onStoppedAnnotationAck(JSONObject jsonObject) {
            try {
                sendEvent("onStoppedAnnotationAck", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
    };


    /*Live transcription observer*/
    EnxTranscriptionObserver enxTranscriptionObserver=new EnxTranscriptionObserver() {
        @Override
        public void onACKStartLiveTranscription(JSONObject jsonObject) {
            try {
                sendEvent("onACKStartLiveTranscription", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onACKStopLiveTranscription(JSONObject jsonObject) {
            try {
                sendEvent("onACKStopLiveTranscription", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onTranscriptionEvents(JSONObject jsonObject) {
            try {
                sendEvent("onTranscriptionEvents", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomTranscriptionOn(JSONObject jsonObject) {
            try {
                sendEvent("onRoomTranscriptionOn", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onRoomTranscriptionOff(JSONObject jsonObject) {
            try {
                sendEvent("onRoomTranscriptionOff", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onSelfTranscriptionOn(JSONObject jsonObject) {
            try {
                sendEvent("onSelfTranscriptionOn", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onSelfTranscriptionOff(JSONObject jsonObject) {
            try {
                sendEvent("onSelfTranscriptionOff", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    };

    EnxHlsStreamObserver enxHlsObserver=new EnxHlsStreamObserver() {
        @Override
        public void onHlsStarted(JSONObject jsonObject) {
            try {
                sendEvent("onHlsStarted", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onHlsStopped(JSONObject jsonObject) {
            try {
                sendEvent("onHlsStopped", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onHlsFailed(JSONObject jsonObject) {
            try {
                sendEvent("onHlsFailed", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onHlsWaiting(JSONObject jsonObject) {
            try {
                sendEvent("onHlsWaiting", EnxUtils.jsonToMap(jsonObject));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
    };

    /*Create common methods for sending events*/
    private void sendEvent(final String eventName, final HashMap map) {
        map.put("event", eventName);
        mEventHandler.post(new Runnable() {
            @Override
            public void run() {
                if (sink != null) {
                    sink.success(map);
                }
            }
        });
    }



    /*Getting all advance option callbacks*/
    private JSONArray getAdvancedOptionsObject(ArrayList<Object> advanceOptions) throws JSONException {
        //        [{"battery_updates":false},{"notify_video_resolution_change":false}]
        JSONObject object = new JSONObject();
        for (int i = 0; i < advanceOptions.size(); i++) {
            if (((HashMap) advanceOptions.get(i)).containsKey("battery_updates")) {
                object.put("battery_updates", ((HashMap) advanceOptions.get(i)).get("battery_updates"));
            } else if (((HashMap) advanceOptions.get(i)).containsKey("notify_video_resolution_change")) {
                object.put("notify_video_resolution_change", ((HashMap) advanceOptions.get(i)).get("notify_video_resolution_change"));
            }
        }

        JSONArray jsonArray = new JSONArray();
        jsonArray.put(object);
        return jsonArray;

    }

    /*Define Room object all required data or parameter*/
    public JSONObject getRoomInfo() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("allow_reconnect", true);
            jsonObject.put("number_of_attempts", 3);
            jsonObject.put("timeout_interval", 15);

            JSONObject object = new JSONObject();
            object.put("activeviews", "list");//view
            object.put("audiomute", true);
            object.put("videomute", false);
            object.put("bandwidth", false);
            object.put("screenshot", false);
            object.put("avatar", true);

            object.put("iconColor", mActivity.getResources().getColor(R.color.colorAccent));
            object.put("iconHeight", 30);
            object.put("iconWidth", 30);
            object.put("avatarHeight", 200);
            object.put("avatarWidth", 200);
            jsonObject.put("playerConfiguration", object);
            jsonObject.put("chat_only", false);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return jsonObject;
    }

    /*Releasing all resources */
    private void releaseAllResources() {

//        if (localStream != null) {
//            localStream.mEnxPlayerView=null;
//        }
//        for (int i = 0; i < mRendererViews.size(); i++) {
//            mRendererViews.get(String.valueOf(i)).removeAllViews();
//        }

        eventChannel = null;
//        sink = null;
//        enxRtc = null;
        localStream = null;
//        mActivity = null;

//        mRendererViews.clear();
//        mRendererViews = null;
        mEnxRoom = null;
        enxRtc = null;
    }


}
