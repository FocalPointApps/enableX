#import "EnxFlutterPlugin.h"
#import <EnxRTCiOS/EnxRtc.h>
#import <EnxRTCiOS/EnxUtilityManager.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <EnxRTCiOS/EnxToolBar.h>//>

#if __has_include(<enx_flutter_plugin/enx_flutter_plugin-Swift.h>)
#import <enx_flutter_plugin/enx_flutter_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "enx_flutter_plugin-Swift.h"

#endif

@interface EnxPlayer ()
@property(nonatomic, strong) UIView *renderView;
@property(nonatomic, assign) int64_t viewId;
@end

@interface EnxToolbarView()
@property(nonatomic, strong) EnxToolBar *toolbarRenderView;
@property(nonatomic, assign) int64_t viewId;
@property(nonatomic,assign) NSDictionary* args;


@end

@implementation EnxPlayer
/* This method will set the frame for the view */
- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId {
    if (self = [super init]) {
        self.renderView = [[UIView alloc] initWithFrame:frame];
        //self.renderView.backgroundColor = [UIColor redColor];
        self.viewId = viewId;
    }
    return self;
}
/* This method will the  view which is not nil*/
- (nonnull UIView *)view {
    return self.renderView;
}


@end

CGSize size;

@implementation EnxToolbarView
/* This method will set the frame for the view */
- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:arg{
    if (self = [super init]) {
       // NSLog(@"get Size %f",size.width);
        self.toolbarRenderView = [[EnxToolBar alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.viewId = viewId;
    }
    return self;
}

/* This method will the  view which is not nil*/
- (nonnull EnxToolBar *)view {
    return self.toolbarRenderView;
}

@end


@interface EnxRenderViewFactory : NSObject <FlutterPlatformViewFactory>
@end

@interface EnxToolbarRenderViewFactory : NSObject <FlutterPlatformViewFactory>
@end

@interface EnxFlutterPlugin () <FlutterStreamHandler,EnxRoomDelegate,EnxStreamDelegate,EnxPlayerDelegate,EnxTroubleShooterDelegate>
@property(strong,nonatomic) FlutterMethodChannel *methodChannel;
@property(strong,nonatomic) FlutterEventChannel *eventChannel;
@property(strong,nonatomic) FlutterEventSink eventSink;
@property(strong,nonatomic) EnxRoom *enxRoom;
@property(strong,nonatomic) EnxRtc *enxRTc;
@property(strong,nonatomic) EnxStream *localStream;
@property(strong, nonatomic) NSMutableDictionary *rendererViews;
//@property(strong, nonatomic) NSMutableDictionary *playerViews;
@property(strong, nonatomic) NSMutableDictionary *streamDictionary;
@property(nonatomic) NSInteger localViewId;
@end

@implementation EnxFlutterPlugin
#pragma mark - renderer views
/* Plugin get initiating here*/
+ (instancetype)sharedPlugin {
    static EnxFlutterPlugin *plugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        plugin = [[EnxFlutterPlugin alloc] init];
    });
    return plugin;
}
/* create and initiate a empty dictonary to store all player view with key = viewID*/
- (NSMutableDictionary *)rendererViews {
    if (!_rendererViews) {
        _rendererViews = [[NSMutableDictionary alloc] init];
    }
    return _rendererViews;
}


/* create and initiate a empty dictonary to store all Stream with key = viewID*/
-(NSMutableDictionary *)streamDictionary{
    if (!_streamDictionary) {
        _streamDictionary = [[NSMutableDictionary alloc] init];
    }
    return _streamDictionary;
}
/* Here we after getting view instance and view id from user we are storing into player dictonary with key = viewID if view is nill we are removing view from player dictonary with key = viewID*/
+ (void)addView:(UIView *)view id:(NSNumber *)viewId {
    if (!viewId) {
        return;
    }
    //Add
    if (view) {
        NSDictionary *viewDict = @{@"view":view};
        [[[EnxFlutterPlugin sharedPlugin] rendererViews] setObject:viewDict forKey:viewId];
        NSLog(@"uiuiuiu %@",viewDict);
    }
    //Remove
    else {
         NSLog(@"removedddd %@",viewId);
        [self removeViewForId:viewId];
    }
}

/* Here we are removing the view from player dictionary with key =viewID*/
+ (void)removeViewForId:(NSNumber *)viewId {
    if (!viewId) {
        return;
    }
    [[[EnxFlutterPlugin sharedPlugin] rendererViews] removeObjectForKey:viewId];
}
/* retur the view which has stored in player dictonary crosponding key = viewId  it may be return a nil value*/
+ (UIView *)viewForId:(NSNumber *)viewId {
    if (!viewId) {
        return nil;
    }
    NSDictionary *viewDict = [[[EnxFlutterPlugin sharedPlugin] rendererViews] objectForKey:viewId];
    NSLog(@"sdcdscaksjc  %@",viewDict);
    if(viewDict == nil){
        return nil;
    }
    if ([viewDict objectForKey:@"view"]) {
        return [viewDict objectForKey:@"view"];
    }else {
        return nil;
    }
}

/* retur the player view crosspond to viewID, which has stored in player dictonary crosponding key = viewId  it may be return a nil value*/
+ (EnxPlayerView *)playerForId:(NSNumber *)viewId {
    if (!viewId) {
        return nil;
    }
    NSDictionary *viewDict = [[[EnxFlutterPlugin sharedPlugin] rendererViews] objectForKey:viewId];
    if(viewDict == nil){
        return nil;
    }
    if ([viewDict objectForKey:@"playerView"]) {
        return [viewDict objectForKey:@"playerView"];
    } else {
        return nil;
    }
}

/*
    Register all class here
 **/

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
               methodChannelWithName:@"enx_flutter_plugin"
                     binaryMessenger:[registrar messenger]];
       FlutterEventChannel *eventChannel = [FlutterEventChannel
               eventChannelWithName:@"enx_flutter_plugin_event_channel"
                    binaryMessenger:registrar.messenger];
       EnxFlutterPlugin *instance = [[EnxFlutterPlugin alloc] init];
       instance.methodChannel = channel;
       instance.eventChannel = eventChannel;
       [registrar addMethodCallDelegate:instance channel:channel];
       
     EnxRenderViewFactory *fac = [[EnxRenderViewFactory alloc] init];
     [registrar registerViewFactory:fac withId:@"EnxPlayer"];

     EnxToolbarRenderViewFactory *enxfac = [[EnxToolbarRenderViewFactory alloc] init];
          [registrar registerViewFactory:enxfac withId:@"EnxToolbarView"];

    
}
/*
    Handle all method/events here
 **/

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
       NSDictionary *params = call.arguments;
       NSLog(@"plugin handleMethodCall: %@, argus: %@", method, params);
       // Core Methods
       if ([@"joinRoom" isEqualToString:method]) {
           NSString *token = [self stringFromArguments:params key:@"token"];
           NSDictionary *publishStreamInfo = [self dictionaryFromArguments:params key:@"localInfo"];
           NSDictionary *roomInfo = [self dictionaryFromArguments:params key:@"roomInfo"];
           NSArray *advanceOptions =[self arrayFromArguments:params key:@"advanceOptions"];
           if(_enxRTc == nil){
               _enxRTc = [[EnxRtc alloc] init];
           }
           _localStream = [_enxRTc joinRoom:token delegate:self PublishStreamInfo:publishStreamInfo roomInfo:roomInfo advanceOptions:advanceOptions];
           _localStream.delegate = self;
           [_eventChannel setStreamHandler:self];
           result(nil);
          }
       else if ([@"publish" isEqualToString:method]){
        if(_enxRoom != nil){
         [_enxRoom publish:_localStream];
         NSDictionary *viewDict = [[[EnxFlutterPlugin sharedPlugin] rendererViews] objectForKey:[NSNumber numberWithInteger:_localViewId]];
            EnxPlayerView *localPlayer;
            if(viewDict != nil){
             localPlayer = (EnxPlayerView *)[viewDict valueForKey:@"playerView"];
            }
         if(localPlayer != nil){
            [_localStream attachRenderer:localPlayer];
           }
         }
         result(nil);
       }
       else if ([@"subscribe" isEqualToString:method]){
         if(params[@"streamId"] != nil){
           EnxStream *remoteStream = [[[EnxFlutterPlugin sharedPlugin] streamDictionary] objectForKey:params[@"streamId"]];
           if(remoteStream != nil){
               [_enxRoom subscribe:remoteStream];
           }
         }
         result(nil);
       }
       else if ([@"disconnect" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom disconnect];
         }
        result(nil);
       }
       else if ([@"startRecord" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom startRecord];
         }
        result(nil);
       }
       else if ([@"stopRecord" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom stopRecord];
         }
        result(nil);
       }
       else if ([@"setTalkerCount" isEqualToString:method]){
        if(_enxRoom != nil){
        NSInteger count = [self intFromArguments:params key:@"count"];
           [_enxRoom setTalkerCount:count];
         }
        result(nil);
       }
       else if ([@"getTalkerCount" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom getTalkerCount];
         }
        result(nil);
       }
       else if ([@"getMaxTalkers" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom getMaxTalkers];
         }
        result(nil);
       }
       else if ([@"enableLogs" isEqualToString:method]){
        if(_enxRoom != nil){
           EnxUtilityManager *logger = [EnxUtilityManager shareInstance];
           [logger startLog];
         }
        result(nil);
       }
       else if ([@"postClientLogs" isEqualToString:method]){
        if(_enxRoom != nil){
             [_enxRoom postClientLogs];
           }
        result(nil);
       }
       else if ([@"requestFloor" isEqualToString:method]){
           if(_enxRoom != nil){
             [_enxRoom requestFloor];
           }
        result(nil);
       }
       else if ([@"grantFloor" isEqualToString:method]){
        if(_enxRoom != nil){
            NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_enxRoom grantFloor:clintId];
         }
        result(nil);
       }
       else if ([@"denyFloor" isEqualToString:method]){
        if(_enxRoom != nil){
            NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_enxRoom denyFloor:clintId];
         }
        result(nil);
       }
       else if ([@"releaseFloor" isEqualToString:method]){
        if(_enxRoom != nil){
            NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_enxRoom releaseFloor:clintId];
         }
        result(nil);
       }
       else if ([@"hardMute" isEqualToString:method]){
        if(_enxRoom != nil){
             [_enxRoom hardMute];
         }
        result(nil);
       }
       else if ([@"hardUnMute" isEqualToString:method]){
        if(_enxRoom != nil){
             [_enxRoom hardUnMute];
         }
        result(nil);
       }
       else if ([@"muteSelfAudio" isEqualToString:method]){
        if(_enxRoom != nil){
         if(_localStream != nil){
          BOOL value = [self boolFromArguments:params key:@"isMute"];
             [_localStream muteSelfAudio:value];
          }
         }
        result(nil);
       }
       else if ([@"muteSelfVideo" isEqualToString:method]){
        if(_enxRoom != nil){
         if(_localStream != nil){
          BOOL value = [self boolFromArguments:params key:@"isMute"];
             [_localStream muteSelfVideo:value];
          }
         }
        result(nil);
       }
       else if ([@"hardMuteAudio" isEqualToString:method]){
        if(_enxRoom != nil){
         if(_localStream != nil){
             NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_localStream hardMuteAudio:clintId];
          }
         }
        result(nil);
       }
       else if ([@"hardUnMuteAudio" isEqualToString:method]){
        if(_enxRoom != nil){
         if(_localStream != nil){
             NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_localStream hardUnMuteAudio:clintId];
          }
         }
        result(nil);
       }
       else if ([@"hardMuteVideo" isEqualToString:method]){
        if(_enxRoom != nil){
         if(_localStream != nil){
             NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_localStream hardMuteVideo:clintId];
          }
         }
        result(nil);
       }
       else if ([@"hardUnMuteVideo" isEqualToString:method]){
        if(_enxRoom != nil){
         if(_localStream != nil){
             NSString *clintId = [self stringFromArguments:params key:@"clinetId"];
             [_localStream hardUnMuteVideo:clintId];
          }
         }
        result(nil);
       }
       else if ([@"switchCamera" isEqualToString:method]){
         if(_localStream != nil){
             [_localStream switchCamera];
          }
        result(nil);
       }
       else if ([@"getAdvancedOptions" isEqualToString:method]){
         if(_enxRoom != nil){
             [_enxRoom getAdvanceOptions];
          }
        result(nil);
       }
       else if ([@"lockRoom" isEqualToString:method]){
         if(_enxRoom != nil){
             [_enxRoom lockRoom];
          }
        result(nil);
       }
       else if ([@"unLockRoom" isEqualToString:method]){
         if(_enxRoom != nil){
             [_enxRoom unlockRoom];
          }
        result(nil);
       }
       else if ([@"makeOutboundCall" isEqualToString:method]){
         if(_enxRoom != nil){
             NSString *number = [self stringFromArguments:params key:@"number"];
             NSString *caller = [self stringFromArguments:params key:@"callerId"];
             [_enxRoom makeOutboundCall:number callerId:caller];
          }
        result(nil);
       }
       else if ([@"cancelOutboundCall" isEqualToString:method]){
                if(_enxRoom != nil){
                    NSString *number = [self stringFromArguments:params key:@"number"];
                    [_enxRoom cancelOutboundCall:number];
                 }
               result(nil);
              }
       else if ([@"extendConferenceDuration" isEqualToString:method]){
         if(_enxRoom != nil){
             [_enxRoom extendConferenceDuration];
          }
        result(nil);
       }
       else if ([@"destroy" isEqualToString:method]){
         if(_enxRoom != nil){
             [_enxRoom destroy];
          }
        result(nil);
       }
       else if ([@"stopVideoTracksOnApplicationBackground" isEqualToString:method]){
         if(_enxRoom != nil){
          BOOL value = [self boolFromArguments:params key:@"videoMuteRemoteStream"];
           [_enxRoom stopVideoTracksOnApplicationBackground:value];
          }
        result(nil);
       }
       else if ([@"startVideoTracksOnApplicationForeground" isEqualToString:method]){
         if(_enxRoom != nil){
          BOOL value = [self boolFromArguments:params key:@"restoreVideoRemoteStream"];
           [_enxRoom startVideoTracksOnApplicationForeground:value];
          }
        result(nil);
       }
       else if ([@"setAudioOnlyMode" isEqualToString:method]){
         if(_enxRoom != nil){
          BOOL value = [self boolFromArguments:params key:@"audioOnly"];
           [_enxRoom setAudioOnlyMode:value];
          }
        result(nil);
       }
       else if ([@"setAudioOnlyMode" isEqualToString:method]){
         if(_enxRoom != nil){
          BOOL value = [self boolFromArguments:params key:@"audioOnly"];
           [_enxRoom setAudioOnlyMode:value];
          }
        result(nil);
       }
       else if ([@"switchMediaDevice" isEqualToString:method]){
         if(_enxRoom != nil){
          NSString *deviceName = [self stringFromArguments:params key:@"deviceName"];
             [_enxRoom switchMediaDevice:deviceName];
          }
        result(nil);
       }
       else if ([@"switchUserRole" isEqualToString:method]){
         if(_enxRoom != nil){
          NSString *clientId = [self stringFromArguments:params key:@"clientId"];
             [_enxRoom switchUserRole:clientId];
          }
        result(nil);
       }
       else if ([@"enableStats" isEqualToString:method]){
         if(_enxRoom != nil){
          BOOL value = [self boolFromArguments:params key:@"enableStats"];
             [_enxRoom enableStats:value];
          }
        result(nil);
       }
       else if ([@"muteSubscribeStreamsAudio" isEqualToString:method]){
         if(_enxRoom != nil){
          BOOL value = [self boolFromArguments:params key:@"isMute"];
             [_enxRoom muteSubscribeStreamsAudio:value];
          }
        result(nil);
       }
       else if ([@"sendMessage" isEqualToString:method]){
         if(_enxRoom != nil){
          NSString *message = [self stringFromArguments:params key:@"message"];
          BOOL isBroadCast = [self boolFromArguments:params key:@"isBroadCast"];
          NSArray *recipientIDs = [self arrayFromArguments:params key:@"recipientIDs"];
          [_enxRoom sendMessage:message isBroadCast:isBroadCast recipientIDs:recipientIDs];
         }
        result(nil);
       }
       else if ([@"sendUserData" isEqualToString:method]){
         if(_enxRoom != nil){
          NSDictionary *message = [self dictionaryFromArguments:params key:@"message"];
          BOOL isBroadCast = [self boolFromArguments:params key:@"isBroadCast"];
          NSArray *recipientIDs = [self arrayFromArguments:params key:@"recipientIDs"];
          [_enxRoom sendUserData:message isBroadCast:isBroadCast recipientIDs:recipientIDs];
         }
        result(nil);
       }
       else if ([@"sendFiles" isEqualToString:method]){
         if(_enxRoom != nil){
        
          BOOL isBroadCast = [self boolFromArguments:params key:@"isBroadCast"];
          NSArray *clientIds = [self arrayFromArguments:params key:@"clientIds"];
            
             [_enxRoom sendFiles:isBroadCast clientIds:clientIds];
         }
        result(nil);
       }
       else if ([@"downloadFile" isEqualToString:method]){
         if(_enxRoom != nil){
          NSDictionary *file = [self dictionaryFromArguments:params key:@"file"];
          BOOL autoSave = [self boolFromArguments:params key:@"autoSave"];
          [_enxRoom downloadFile:file autoSave:autoSave];
         }
        result(nil);
       }
       else if ([@"cancelUpload" isEqualToString:method]){
         if(_enxRoom != nil){
          NSInteger jobId = [self intFromArguments:params key:@"jobId"];
          [_enxRoom cancelUpload:jobId];
         }
        result(nil);
       }
       else if ([@"cancelAllUploads" isEqualToString:method]){
         if(_enxRoom != nil){
          [_enxRoom cancelAllUploads];
         }
        result(nil);
       }
       else if ([@"cancelDownload" isEqualToString:method]){
         if(_enxRoom != nil){
          NSInteger jobId = [self intFromArguments:params key:@"jobId"];
          [_enxRoom cancelDownload:jobId];
         }
        result(nil);
       }
       else if ([@"cancelAllDownloads" isEqualToString:method]){
         if(_enxRoom != nil){
          [_enxRoom cancelAllDownloads];
         }
        result(nil);
       }
       else if ([@"dropUser" isEqualToString:method]){
         if(_enxRoom != nil){
          NSArray *clientIds = [self arrayFromArguments:params key:@"clientIds"];
          [_enxRoom dropUser:clientIds];
         }
        result(nil);
       }
       else if ([@"getUserList" isEqualToString:method]){
           NSArray *userList;
        if(_enxRoom != nil){
          userList = [_enxRoom getUserList];
         }
        result(userList);
       }
       else if ([@"getReceiveVideoQuality" isEqualToString:method]){
           NSString *quality;
        if(_enxRoom != nil){
          NSString *streamType = [self stringFromArguments:params key:@"streamType"];
          quality = [_enxRoom getReceiveVideoQuality:streamType];
         }
        result(quality);
       }
       else if ([@"Whoami" isEqualToString:method]){
           NSDictionary *whoami;
        if(_enxRoom != nil){
          whoami = [_enxRoom Whoami];
         }
        result(whoami);
       }
       else if ([@"getDevices" isEqualToString:method]){
           NSArray *getDevices;
        if(_enxRoom != nil){
          getDevices = [_enxRoom getDevices];
         }
        result(getDevices);
       }
       else if ([@"getSelectedDevice" isEqualToString:method]){
           NSString *getSelectedDevice;
        if(_enxRoom != nil){
          getSelectedDevice = [_enxRoom getSelectedDevice];
         }
        result(getSelectedDevice);
       }
       else if ([@"getAvailableFiles" isEqualToString:method]){
           NSArray *getAvailableFiles;
        if(_enxRoom != nil){
          getAvailableFiles = [_enxRoom getAvailableFiles];
         }
        result(getAvailableFiles);
       }
       else if ([@"getRoomId" isEqualToString:method]){
           NSString *roomId = @"";
        if(_enxRoom != nil){
          roomId = _enxRoom.roomId;
         }
        result(roomId);
       }
       else if ([@"getClientName" isEqualToString:method]){
           NSString *clientName = @"";
        if(_enxRoom != nil){
          clientName = _enxRoom.clientName;
         }
        result(clientName);
       }
       else if ([@"getRole" isEqualToString:method]){
           NSString *getRole = @"";
        if(_enxRoom != nil){
          getRole = _enxRoom.userRole;
         }
        result(getRole);
       }
       else if ([@"getClientId" isEqualToString:method]){
           NSString *clientId = @"";
        if(_enxRoom != nil){
          clientId = _enxRoom.clientId;
         }
        result(clientId);
       }
       else if ([@"isRoomActiveTalker" isEqualToString:method]){
           BOOL isRoomActiveTalker = false;
        if(_enxRoom != nil){
          isRoomActiveTalker = _enxRoom.isRoomActiveTalker;
         }
        result([NSNumber numberWithBool:isRoomActiveTalker]);
       }
       else if ([@"cancelFloor" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom cancelFloor];
         }
        result(nil);
       }
       else if ([@"finishFloor" isEqualToString:method]){
        if(_enxRoom != nil){
           [_enxRoom finishFloor];
         }
        result(nil);
       }

    else if ([@"inviteToFloor" isEqualToString:method]){
               if(_enxRoom != nil){
                 NSString *clintId = [self stringFromArguments:params key:@"clientId"];
                  [_enxRoom inviteToFloor:clintId];
                }
               result(nil);
              }
    else if ([@"acceptInviteFloorRequest" isEqualToString:method]){
               if(_enxRoom != nil){
                 NSString *clintId = [self stringFromArguments:params key:@"clientId"];
                  [_enxRoom acceptInviteFloorRequest:clintId];
                }
               result(nil);
              }

    else if ([@"cancelFloorInvite" isEqualToString:method]){
               if(_enxRoom != nil){
               NSString *clintId = [self stringFromArguments:params key:@"clientId"];
               [_enxRoom cancelFloorInvite:clintId];
               }
               result(nil);
               }
    else if ([@"rejectInviteFloor" isEqualToString:method]){
             if(_enxRoom != nil){
             NSString *clintId = [self stringFromArguments:params key:@"clientId"];
             [_enxRoom rejectInviteFloor:clintId];
             }
             result(nil);
             }
       //
       else if ([@"enableProximitySensor" isEqualToString:method]){
        if(_enxRoom != nil){
             BOOL value = [self boolFromArguments:params key:@"isEnabled"];
           [_enxRoom enableProximitySensor:value];
         }
        result(nil);
       }
       else if ([@"config" isEqualToString:method]){
        if(_enxRoom != nil){
             NSDictionary *value = [self dictionaryFromArguments:params key:@"config"];
           [_enxRoom updateConfiguration:value];
         }
        result(nil);
       }
    else if ([@"setupVideo" isEqualToString:method]) {
        NSInteger viewId = [self intFromArguments:params key:@"viewId"];
        NSLog(@"*******######VideiD of the View %d######**********",viewId);
        UIView *view = [EnxFlutterPlugin viewForId:@(viewId)];
        float height = 0.0;
        float width = 0.0;
        if(params[@"height"] != nil){
            height = [params[@"height"] floatValue];
        }
        if(params[@"width"] != nil){
            width = [params[@"width"] floatValue];
        }
        if(params[@"uid"] == nil){
            return;
        }
        if([params[@"isLocal"] boolValue] == true){
                EnxPlayerView *localView = [EnxFlutterPlugin playerForId:@(viewId)];
                _localViewId = viewId;
                if(localView != nil){
                  [localView removeFromSuperview];
                }
               else {
                   NSLog(@"******This is the Local View Call******");
                 localView = [[EnxPlayerView alloc] initLocalView:CGRectMake(0, 0, width, height)];
                 localView.delegate = self;
                   NSDictionary *viewDict = @{@"view":view,@"playerView":localView};
                 [[[EnxFlutterPlugin sharedPlugin] rendererViews] setObject:viewDict forKey:@(viewId)];
                }
                localView.clipsToBounds = true;
                 [view addSubview:localView];
            }
            else {
                NSLog(@"******This is the remore View Call with ViewId %d******",viewId);
            [self checkAndRemoveView:[params[@"uid"]stringValue]];
            EnxPlayerView *remoteView = [EnxFlutterPlugin playerForId:@(viewId)];
             if(remoteView != nil){
                 [remoteView removeFromSuperview];
             }
             else{
            remoteView = [[EnxPlayerView alloc] initRemoteView:CGRectMake(0, 0, width, height)];
            remoteView.delegate = self;
            NSDictionary *viewDict = @{@"view":view,@"playerView":remoteView,@"streamId":[params[@"uid"]stringValue]};
            [[[EnxFlutterPlugin sharedPlugin] rendererViews] setObject:viewDict forKey:@(viewId)];
             }
            remoteView.clipsToBounds = true;
            [view addSubview:remoteView];
            EnxStream *stream =(EnxStream *)[[[EnxFlutterPlugin sharedPlugin] streamDictionary] valueForKey:[params[@"uid"]stringValue]];
            if(stream != nil){
                    [stream attachRenderer:remoteView];
                }
            }
       result(nil);
    }
    else if ([@"captureScreenShot" isEqualToString:method]){
      if(_enxRoom != nil){
       NSString *streamId = [self stringFromArguments:params key:@"streamId"];
          if(streamId.length>4){
              NSDictionary * viewDict = [[EnxFlutterPlugin sharedPlugin] rendererViews][@(_localViewId)];
              EnxPlayerView *playerView = viewDict[@"playerView"];
              if (playerView != nil){
                  [playerView captureScreenShot];
              }
          }else{
              NSArray *keyArray=[[[EnxFlutterPlugin sharedPlugin] rendererViews]allKeys];
              NSLog(@"all keys%@",keyArray);
           for (NSString* key in keyArray) {
               
               NSDictionary * viewDict = [[EnxFlutterPlugin sharedPlugin] rendererViews][key];
               if([viewDict[@"streamId"] isEqualToString:streamId]){
                  
                   EnxPlayerView *playerView = viewDict[@"playerView"];
                   if (playerView != nil){
                       [playerView captureScreenShot];
                   }
                   break;
               }
             
           }
          }
          }
       
     result(nil);
    }
    else if ([@"pinUsers" isEqualToString:method]){
        if(_enxRoom != nil){
            NSArray *userList = [self arrayFromArguments:params key:@"userList"];
            [_enxRoom pinUsers:userList];
        }
         result(nil);
       }
       else if ([@"unpinUsers" isEqualToString:method]){
        if(_enxRoom != nil){
            NSArray *userList = [self arrayFromArguments:params key:@"userList"];
            [_enxRoom unpinUsers:userList];
        }
         result(nil);
       
       }else if ([@"approveAwaitedUser" isEqualToString:method]){
                 if(_enxRoom != nil){
                    NSString *clintId = [self stringFromArguments:params key:@"clientId"];
                     [_enxRoom approveAwaitedUser:clintId];
                 }
                  result(nil);
               }else if ([@"denyAwaitedUser" isEqualToString:method]){
                     if(_enxRoom != nil){
                       NSString *clintId = [self stringFromArguments:params key:@"clientId"];
                       [_enxRoom approveAwaitedUser:clintId];
                     }
                      result(nil);

    }else if([@"subscribeForTalkerNotification" isEqualToString:method]){
            if(_enxRoom != nil){
           BOOL value = [self boolFromArguments:params key:@"isTalkerNotification"];
            [_enxRoom subscribeForTalkerNotification:value];
        }
         result(nil);
       }
    else if([@"createBreakOutRoom" isEqualToString:method]){
                   if(_enxRoom != nil){
                  NSDictionary *createBreakoutInfo = [self dictionaryFromArguments:params key:@"createBreakoutInfo"];
                  [_enxRoom createBreakOutRoom:createBreakoutInfo];
               }
                result(nil);
              }

    else if([@"createAndInviteBreakoutRoom" isEqualToString:method]){
             if(_enxRoom != nil){
              NSDictionary *createandInviteBreakOutInfo = [self dictionaryFromArguments:params key:@"createandInviteBreakOutInfo"];


               [_enxRoom createAndInviteBreakoutRoom:createandInviteBreakOutInfo];
                }
              result(nil);
               }
    else if([@"joinBreakOutRoom" isEqualToString:method]){
             if(_enxRoom != nil){
              NSDictionary *dataInfo = [self dictionaryFromArguments:params key:@"dataInfo"];
              NSDictionary *streamInfo = [self dictionaryFromArguments:params key:@"streamInfo"];

              [_enxRoom joinBreakOutRoom:dataInfo withStreamInfo:streamInfo];
              }
              result(nil);
              }
    else if([@"inviteToBreakOutRoom" isEqualToString:method]){
             if(_enxRoom != nil){
             NSDictionary *inviteBreakOutInfo = [self dictionaryFromArguments:params key:@"inviteBreakOutInfo"];


             [_enxRoom inviteToBreakOutRoom:inviteBreakOutInfo];
             }
             result(nil);
             }
    else if([@"pause" isEqualToString:method]){
             if(_enxRoom != nil){


            [_enxRoom pause];
            }
            result(nil);
            }
    else if([@"resume" isEqualToString:method]){
            if(_enxRoom != nil){

            [_enxRoom resume];
             }
             result(nil);
             }
    else if([@"muteRoom" isEqualToString:method]){
                if(_enxRoom != nil){
                NSDictionary *muteRoomInfo = [self dictionaryFromArguments:params key:@"muteRoomInfo"];


                [_enxRoom muteRoom:muteRoomInfo];
                }
                result(nil);
                }
   else if([@"unmuteRoom" isEqualToString:method]){
          if(_enxRoom != nil){
          NSDictionary *unMuteRoomInfo = [self dictionaryFromArguments:params key:@"unMuteRoomInfo"];
          [_enxRoom unmuteRoom:unMuteRoomInfo];
          }
          result(nil);
          }

     else if([@"rejectBreakOutRoom" isEqualToString:method]){
            if(_enxRoom != nil){
               NSString *breakoutRoomId = [self stringFromArguments:params key:@"breakoutRoomId"];

              [_enxRoom rejectBreakOutRoom:breakoutRoomId];
             }
             result(nil);
             }


          else if ([@"clientDiagnostics" isEqualToString:method]){
             
               NSDictionary *optionInfo = [self dictionaryFromArguments:params key:@"optionInfo"];
                 if(_enxRTc == nil){
                     _enxRTc = [[EnxRtc alloc] init];
                     _enxRTc.delegate=self;
                 }

               if(_enxRTc != nil){
            
              [_enxRTc clientDiagnostics:optionInfo];

                 }
                   [_eventChannel setStreamHandler:self];
                 result(nil);
               }
            else if ([@"addSpotlightUsers" isEqualToString:method]){
             if(_enxRoom != nil){
             NSArray *userList = [self arrayFromArguments:params key:@"userList"];
              [_enxRoom addSpotlightUsers:userList];
                 }
                 result(nil);
               }
         else if ([@"removeSpotlightUsers" isEqualToString:method]){
         if(_enxRoom != nil){
         NSArray *userList = [self arrayFromArguments:params key:@"userList"];
         [_enxRoom removeSpotlightUsers:userList];
          }
          result(nil);

         }
         else if ([@"switchRoomMode" isEqualToString:method]){
         if(_enxRoom != nil){
             NSString *mode = [self stringFromArguments:params key:@"roomMode"];
          
         [_enxRoom switchRoomMode:mode];
          }
          result(nil);

         }
         else if ([@"startStreaming" isEqualToString:method]){
         if(_enxRoom != nil){
          
             NSDictionary *startStreamingObject = [self dictionaryFromArguments:params key:@"streamingDetails"];
          
         [_enxRoom startStreaming:startStreamingObject];
          }
          result(nil);

         }
         else if ([@"stopStreaming" isEqualToString:method]){
         if(_enxRoom != nil){
             NSDictionary *stopStreamingObject = [self dictionaryFromArguments:params key:@"streamingDetails"];
          
         [_enxRoom stopStreaming:stopStreamingObject];
          }
          result(nil);
         }
         /*Live Recording */
        else if ([@"startLiveRecording" isEqualToString:method]){
         if(_enxRoom != nil){
             NSDictionary *startStreamingObject = [self dictionaryFromArguments:params key:@"streamingDetails"];
            [_enxRoom startLiveRecording:startStreamingObject];
          }
          result(nil);
         }
         else if ([@"stopLiveRecording" isEqualToString:method]){
         if(_enxRoom != nil){
            [_enxRoom stopLiveRecording];
          }
          result(nil);
         }
          else if ([@"hardMuteUserAudio" isEqualToString:method]){
                  if(_enxRoom != nil){
                     NSString *clintId = [self stringFromArguments:params key:@"clientId"];
                     [_enxRoom hardMuteUserAudio:clintId];
                   }
                   result(nil);
                  }
        else if ([@"hardUnmuteUserAudio" isEqualToString:method]){
           if(_enxRoom != nil){
                      NSString *clintId = [self stringFromArguments:params key:@"clientId"];
               [_enxRoom hardUnmuteUserAudio:clintId];
          }
          result(nil);
         }
         else if ([@"hardMuteUserVideo" isEqualToString:method]){
           if(_enxRoom != nil){
                      NSString *clintId = [self stringFromArguments:params key:@"clientId"];
               [_enxRoom hardMuteUserVideo:clintId];
          }
          result(nil);
         }
        else if ([@"hardUnmuteUserVideo" isEqualToString:method]){
           if(_enxRoom != nil){
                      NSString *clintId = [self stringFromArguments:params key:@"clientId"];
            [_enxRoom hardUnmuteUserVideo:clintId];
          }
          result(nil);
         }
          else if ([@"highlightBorderForClient" isEqualToString:method]){
                    if(_enxRoom != nil){
             NSArray *clintId = [self arrayFromArguments:params key:@"clientId"];
                     [_enxRoom highlightBorderForClient:clintId];
                   }
                   result(nil);
                  }

       else if ([@"changeBgColorForClients" isEqualToString:method]){
                    if(_enxRoom != nil){
             NSArray *clintId = [self arrayFromArguments:params key:@"clientId"];
             NSString *color = [self stringFromArguments:params key:@"color"];
                        UIColor *finalColor = [self colorFromHexString:color];
                        [_enxRoom changeBgColorForClients:clintId withColor:finalColor];
                   }
                   result(nil);
                  }

      else if([@"startAnnotation" isEqualToString:method]){

            NSString *annotationStreamId = [self stringFromArguments:params key:@"streamId"];
           if(annotationStreamId != nil){
           EnxStream *annotationStream = [[[EnxFlutterPlugin sharedPlugin] streamDictionary] objectForKey:annotationStreamId];
           if(annotationStream != nil){
               [_enxRoom startAnnotation:annotationStream];
           }
         }
         result(nil);
      }
      else if([@"stopAnnotation" isEqualToString:method]){
               if(_enxRoom != nil){
                  [_enxRoom stopAnnotation];
                }
                result(nil);


      }
      else if([@"setupToolbar" isEqualToString:method]){
          size.width = [self intFromArguments:params key:@"width"];
          size.height = [self intFromArguments:params key:@"height"];
//          NSInteger viewWidth = [self intFromArguments:params key:@"width"];
//          NSInteger viewHeight = [self intFromArguments:params key:@"height"];
            
            
          result(nil);

          
      }
       else if([@"startLiveTranscription" isEqualToString:method]){
                     if(_enxRoom != nil){
                            NSString *lang = [self stringFromArguments:params key:@"language"];
                        [_enxRoom startLiveTranscription:lang];
                      }
                      result(nil);


            }
            else if([@"startLiveTranscriptionForRoom" isEqualToString:method]){
                                 if(_enxRoom != nil){
                                        NSString *language = [self stringFromArguments:params key:@"language"];
                                    [_enxRoom startLiveTranscriptionForRoom:language];
                                  }
                                  result(nil);


                        }
             else if([@"stopLiveTranscription" isEqualToString:method]){
                           if(_enxRoom != nil){
                              [_enxRoom stopLiveTranscription];
                            }
                            result(nil);


                  }

       else {
        result(FlutterMethodNotImplemented);
           }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


/*
    Check if view exit with streamID and remove that view
 **/
-(void)checkAndRemoveView:(NSString * _Nonnull)streamId{
 for (NSString* key in [[EnxFlutterPlugin sharedPlugin] rendererViews]) {
    NSDictionary * viewDict = [[EnxFlutterPlugin sharedPlugin] rendererViews][key];
    if([viewDict[@"streamId"] isEqualToString:streamId]){
        EnxPlayerView *playerView = viewDict[@"playerView"];
        [playerView removeFromSuperview];
        [EnxFlutterPlugin removeViewForId:[NSNumber numberWithInteger:[key integerValue]]];
        break;
    }
  }
}
/*
    Remove tyhe instance of object
 **/

- (void)dealloc {
    [self.methodChannel setMethodCallHandler:nil];
    [self.eventChannel setStreamHandler:nil];
}

#pragma mark - FlutterStreamHandler
/*
 Cancle listner argument
 **/
- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)params {
    _eventSink = nil;
    return nil;
}
/*
 add listner argument
 **/
- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)params eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}
/*
 Notify to the event listener with name and parameter
 **/

- (void)sendEvent:(NSString * _Nonnull)name params:(NSDictionary * _Nonnull)params {
    if (_eventSink) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:params];
        dict[@"event"] = name;
        _eventSink([dict copy]);
    }
}


#pragma mark - helper
/*
 get the stored value from parames dictonary and return as NSString, not may contain nil value
 **/
- (NSString * _Nullable)stringFromArguments:(NSDictionary * _Nonnull)params key:(NSString *_Nonnull)key {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSString *value = [params valueForKey:key];
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    } else {
        return value;
    }
}
/*
 get the stored value from parames dictonary and return as NSDictionary, not may contain nil value
 **/
- (NSDictionary * _Nullable)dictionaryFromArguments:(NSDictionary * _Nonnull)params key:(NSString * _Nonnull)key {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSDictionary *value = [params valueForKey:key];
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    } else {
        return value;
    }
}
/*
 get the stored value from parames dictonary and return as NSArray, not may contain nil value
 **/
- (NSArray * _Nullable)arrayFromArguments:(NSDictionary *_Nonnull)params key:(NSString *_Nonnull)key {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSArray *value = [params valueForKey:key];
    if (![value isKindOfClass:[NSArray class]]) {
        return nil;
    } else {
        return value;
    }
}
/*
 get the stored value from parames dictonary and return as NSInteger, not may contain 0 value
 **/
- (NSInteger)intFromArguments:(NSDictionary *_Nonnull)params key:(NSString *_Nonnull)key {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return 0;
    }

    NSNumber *value = [params valueForKey:key];
    if (![value isKindOfClass:[NSNumber class]]) {
        return 0;
    } else {
        return [value integerValue];
    }
}
/*
 get the stored value from parames dictonary and return as BOOL, not may contain 0 value
 **/
- (BOOL)boolFromArguments:(NSDictionary *_Nonnull)params key:(NSString *_Nonnull)key {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return NO;
    }

    NSNumber *value = [params valueForKey:key];
    if (![value isKindOfClass:[NSNumber class]]) {
        return NO;
    } else {
        return [value boolValue];
    }
}


#pragma mark - EnxRTCiOS_Room Delegate

//Mark - EnxRoom Delegates
/*
 This Delegate will notify to User Once he got succes full join Room with room instance, which has stored in plugin and roommetadata has passed to users
 */

-(void)room:(EnxRoom * _Nullable)room didConnect:(NSDictionary * _Nullable)roomMetadata{
    NSLog(@"connectedddd");
    _enxRoom = room;
    [self sendEvent:@"onRoomConnected" params:roomMetadata];
}

/*
 This Delegate will notify to User Once he Getting error in joining room
 */
- (void)room:(EnxRoom *_Nullable)room didError:(NSArray *_Nullable)reason {
    NSLog(@"roomErrrorrr:  %@",reason);
    if(reason == nil || reason.count == 0){
        return;
    }
    [self sendEvent:@"onRoomError" params:reason[0]];
}
/*
 This Delegate will notify to User Once any event get failed with valid reasion
 */
-(void)room:(EnxRoom * _Nullable)room didEventError:(NSArray * _Nullable)reason{
     NSLog(@"eventErrrorrr:  %@",reason);
    if(reason == nil || reason.count == 0){
         return;
     }
     [self sendEvent:@"onEventError" params:reason[0]];
}
/**
  This delegate method will notify to the user , who try to consume any EnxRoom API or EnxStream API with details for the events
 */
-(void)room:(EnxRoom * _Nullable)room didEventInfo:(NSDictionary * _Nullable)infoData{
    if(infoData == nil){
        return;
    }
    [self sendEvent:@"onEventInfo" params:infoData];
}
/**
 This room event will notify to the user, who has published their owne stream after connected to room
 */
-(void)room:(EnxRoom * _Nullable)room didPublishStream:(EnxStream * _Nullable)stream{
    
       if(stream == nil){
            return;
        }
      NSArray *keyArray=[[[EnxFlutterPlugin sharedPlugin] rendererViews]allKeys];
//      for (NSString* key in keyArray) {
//          if([key intValue] == _localViewId){
//              NSDictionary * viewDict = [[EnxFlutterPlugin sharedPlugin] rendererViews][key];
//              [[[EnxFlutterPlugin sharedPlugin] rendererViews] removeObjectForKey:key];
//              [[[EnxFlutterPlugin sharedPlugin] rendererViews] setObject:viewDict forKey:stream.streamId];
//              _localViewId=[stream.streamId intValue];
//              break;
//          }
// }
  
        [[[EnxFlutterPlugin sharedPlugin] streamDictionary] setValue:stream forKey:stream.streamId];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
        if (stream.streamId != nil){
            
            [dict setValue:stream.streamId forKey:@"streamId"];
        }
    [dict setValue:@"The stream has been published." forKey:@"msg"];
    [dict setValue:@"0" forKey:@"result"];
        [self sendEvent:@"onPublishedStream" params:dict];
    
}
/**
 This delegate method will notify to current user after room disconnect success , Disconnect happen either by self or by modiatore or by room duration exrire.
 Here "response" will carry information about disconnection of room
 */
-(void)didRoomDisconnect:(NSArray * _Nullable)response{
    if(response == nil || response.count == 0){
        return;
    }
    [self sendEvent:@"onRoomDisConnected" params:response[0]];
    [self releaseObjects];
}
/**
 This delegate method will inform to all partipient/moderator in same confrence with details information about the user who has just disconnected from confrence.
 */
-(void)room:(EnxRoom * _Nullable)room userDidDisconnected:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onUserDisConnected" params:Data[0]];
}
/**
 This delegate method will inform to all partipient/moderator in same confrence with details information about the user who has just join the room.
 */
-(void)room:(EnxRoom *_Nullable)room userDidJoined:(NSArray *_Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onUserConnected" params:Data[0]];
}
/**
 This delegate method called to receive custom signaling event message at room Level.
 */
-(void)room:(EnxRoom *_Nonnull)room didUserDataReceived:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onUserDataReceived" params:data[0]];
}
/**
 This delegates methods get called, when any participent will exchanges chat message in same room.
 */
-(void)room:(EnxRoom * _Nonnull)room didMessageReceived:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onMessageReceived" params:data[0]];
}
/*
EnxStream object (not subscribed yet), that were just added
 to the room.
 **/
-(void)room:(EnxRoom * _Nullable)room didAddedStream:(EnxStream * _Nullable)stream{
    
    if(stream == nil){
        return;
    }
    [[[EnxFlutterPlugin sharedPlugin] streamDictionary] setValue:stream forKey:stream.streamId];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (stream.streamId != nil){
        [dict setValue:stream.streamId forKey:@"streamId"];
    }
    [dict setValue:[NSNumber numberWithBool:stream.hasData] forKey:@"hasData"];
    [dict setValue:[NSNumber numberWithBool:stream.screen] forKey:@"hasScreen"];
    [self sendEvent:@"onStreamAdded" params:dict];
}
/*
 once any participent successfully completed subscription of all avaialble stream in same confrence will receive available active talker list.
 **/
-(void)room:(EnxRoom * _Nullable)room didActiveTalkerList:(NSArray * _Nullable)Data{
   @try{
    if(Data == nil || Data.count == 0){
     [self sendEvent:@"onActiveTalkerList" params:@{@"activeList":@[]}];
        return;
    }
       NSMutableArray *atArray= [NSMutableArray arrayWithCapacity:0];
       for(EnxStream *stream in Data){
           NSDictionary *tempDict = @{@"streamId":(stream.streamId != nil ? stream.streamId:@""),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"mediatype":(stream.mediaType!= nil ? stream.mediaType:@""),@"name":(stream.name!= nil ? stream.name:@""),@"reason":(stream.reasonForMuteVideo!= nil ? stream.reasonForMuteVideo:@""),@"videomuted":[NSNumber numberWithBool:stream.isSelfVideoMuted],@"videoaspectratio":(stream.videoAspectRatio!= nil ? stream.videoAspectRatio:@"")};
           [atArray addObject:tempDict];
           
//           for (NSString* key in [[EnxFlutterPlugin sharedPlugin] rendererViews]) {
//             NSDictionary * viewDict = [[EnxFlutterPlugin sharedPlugin] rendererViews][key];
//             if([viewDict[@"streamId"] isEqualToString:stream.streamId]){
//                 EnxPlayerView *playerView = viewDict[@"playerView"];
//                 if(stream != nil && playerView != nil){
//                     [stream attachRenderer:playerView];
//               }
//              break;
//             }
//           }
       }
   /* NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < Data.count; i++) {
     EnxStream *stream = (EnxStream *)Data[i];
        NSString *streamId = @"";
        NSString *clientId = @"";
        NSString *mediatype = @"";
        NSString *name = @"";
        NSString *reason = @"";
        NSString *videoaspectratio = @"";
        if(stream.streamId != nil){
            streamId = stream.streamId;
        }
        if(stream.clientId != nil){
            clientId = stream.clientId;
        }
        if(stream.mediaType != nil){
            mediatype = stream.mediaType;
        }
        if(stream.name != nil){
            name = stream.name;
        }
        if(stream.videoAspectRatio != nil){
            videoaspectratio = stream.videoAspectRatio;
        }
        if(stream.reasonForMuteVideo != nil){
            reason = stream.reasonForMuteVideo;
        }
        NSDictionary *tempDict = @{@"streamId":streamId,@"clientId":clientId,@"mediatype":mediatype,@"name":name,@"reason":reason,@"videomuted":[NSNumber numberWithBool:stream.isSelfVideoMuted],@"videoaspectratio":videoaspectratio};
     [array insertObject:tempDict atIndex:i];
        for (NSString* key in [[EnxFlutterPlugin sharedPlugin] rendererViews]) {
          NSDictionary * viewDict = [[EnxFlutterPlugin sharedPlugin] rendererViews][key];
          if([viewDict[@"streamId"] isEqualToString:stream.streamId]){
              EnxPlayerView *playerView = viewDict[@"playerView"];
              if(stream != nil && playerView != nil){
                  [stream attachRenderer:playerView];
            }
           break;
          }
        }
     
    }*/
      
    [self sendEvent:@"onActiveTalkerList" params:@{@"activeList":atArray}];
   }
   @catch(NSException *error){
       NSLog(@"%@",error.description);
    }
}
/*This delegate called, when any moderatore has switched their role or hand over their role to any of the participent in same room.*/

-(void)room:(EnxRoom *_Nullable)room didSwitchUserRole:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onSwitchedUserRole" params:data[0]];
}
/*
 This is an acklodgment method for destroy room, Moderatore can destroy room  at any time.
 **/
-(void)room:(EnxRoom * _Nullable)room didAckDestroy:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckDestroy" params:data[0]];
}
/*
 This is an acklodgment method for dropuser, Moderatore can drop any user at any time.
 **/
-(void)room:(EnxRoom *_Nullable)room didAckDropUser:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckDropUser" params:data[0]];
}
/*
 This delegate called for all participent in same confrence, 5mint before confrence duration.
 **/
-(void)room:(EnxRoom * _Nullable)room didConferenceRemainingDuration:(NSArray * _Nullable)data{
   if(data == nil || data.count == 0){
       return;
   }
   [self sendEvent:@"onConferenceRemainingDuration" params:data[0]];
}
/*
 This delegate called for all participent in same confrence, once any of moderatore has exted the confrence duration.
 **/
-(void)room:(EnxRoom *_Nullable)room didConferencessExtended:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onConferencessExtended" params:data[0]];
}
/*
 All particpents/Moderator in room will receive this delegate method once recoding has started in same confrence
 **/
-(void)roomRecordOn:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomRecordingOn" params:Data[0]];
}
/*
 This delegate method will notify to all end users, once room recording has started successfully.
 **/
-(void)startRecordingEvent:(NSArray * _Nullable)response{
    if(response == nil || response.count == 0){
        return;
    }
    [self sendEvent:@"onStartRecordingEvent" params:response[0]];
}
/*
 All particpents/Moderator in room will receive this delegate method once recoding has stopped in same confrence
 **/
-(void)roomRecordOff:(NSArray *_Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomRecordingOff" params:Data[0]];
}
/*
 This delegate method will notify to all end users, once room recording has stopped successfully.
 **/
-(void)stopRecordingEvent:(NSArray * _Nullable)response{
    if(response == nil || response.count == 0){
        return;
    }
    [self sendEvent:@"onStopRecordingEvent" params:response[0]];
}
/*
 This delegate method will fired once user will request to set active talker in same confrence.
 **/
-(void)room:(EnxRoom * _Nullable)room didSetTalkerCount:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onSetTalkerCount" params:Data[0]];
}
/*
 with the help of this delegate methoder, use can check current number of active taker in same confrence.
 **/
-(void)room:(EnxRoom * _Nullable)room didGetTalkerCount:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onGetTalkerCount" params:Data[0]];
}
/*
 this delegate method will give information about max  possible active talker in same confrence. so that user can change any number of active talker which is less than possible active talkers in room. User can request to know max possible AT in room at any time after join room.
 **/
-(void)room:(EnxRoom * _Nullable)room didGetMaxTalkers:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onMaxTalkerCount" params:Data[0]];
}
/*
 This delegate method will inform to self user , who is uploading their sdk logs to server.
 **/
-(void)didLogUpload:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onLogUploaded" params:data[0]];
}
/*
 This delegate method will inform to all use in confrence, whenever any bandwidth update hapen by server in same room.
 **/
-(void)room:(EnxRoom * _Nullable)room didBandWidthUpdated:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onBandWidthUpdated" params:data[0]];
}
/*
 This delegate method will inform to the current user , share screen state changes due to any cause like low bandwidth.
 **/
-(void)room:(EnxRoom * _Nullable)room didShareStreamEvent:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onShareStreamEvent" params:data[0]];
}
/*
 data CanvasStateEvent info on a stream.
 **/
-(void)room:(EnxRoom * _Nullable)room didCanvasStreamEvent:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onCanvasStreamEvent" params:data[0]];
}
/*
 This delegate method will inform to user, if he/she has network clunch during call.
 **/
-(void)room:(EnxRoom * _Nonnull)room didConnectionInterrupted:(NSArray * _Nonnull)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onConnectionInterrupted" params:data[0]];
}
/*
 this delegate method will call when network will not resume within given time out time.
 **/
-(void)room:(EnxRoom * _Nonnull)room didConnectionLost:(NSArray * _Nonnull)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onConnectionLost" params:data[0]];
}
/*
 This delegate method for participent who requested for floor access.
 **/
-(void)didFloorRequested:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onFloorRequested" params:Data[0]];
}
/*
 There would be listener for participant and moderator when participant request floor. For this delegates are:
 **/
-(void)didFloorRequestReceived:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onFloorRequestReceived" params:Data[0]];
}
/*
 Here, Data is result form EnxServer on grantFloor,releaseFloor and denyFloor event.
 **/
-(void)didProcessFloorRequested:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onProcessFloorRequested" params:Data[0]];
}
/*
 This API is only available during Lecture Mode. Each Participant requested Floor Control can individually be granted access to the Floor using this API Call. These API calls are only available to users with role “Moderator”.
 **/
-(void)didGrantFloorRequested:(NSArray * _Nonnull)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onGrantedFloorRequest" params:Data[0]];
}
/*
 This API is only available during Lecture Mode of a Session. Each Participant requested Floor Control can individually be denied access to the Floor using this API Call. This API calls are only available to users with role “Moderator”.
 **/
-(void)didDenyFloorRequested:(NSArray * _Nonnull)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onDeniedFloorRequest" params:Data[0]];
}
/*
 This API is only available during Lecture Mode of a Session. Each Participant granted Floor Control can individually be asked to release the floor Control using this API Call. This API calls are only available to users with role “Moderator”.
 **/
-(void)didReleaseFloorRequested:(NSArray * _Nonnull)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onReleasedFloorRequest" params:Data[0]];
}

/*
  This is an acknowledgment method for the inviteToFloor to the moderator.
 **/

-(void)didACKInviteToFloorRequested:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"didACKInviteToFloorRequested" params:Data[0]];
}

/*
 This event method will notify to all moderator in the same session (including the owner of the event), that invitation received by participant
  **/
-(void)didInviteToFloorRequested:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onInviteToFloorRequested" params:Data[0]];
}
/*
 This delegate method for Participant , How or she will receive handover floor access.
  **/
-(void)didInvitedForFloorAccess:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onInvitedForFloorAccess" params:Data[0]];
}
/*
 This is an event method for the all  moderator including owner of the API and participant which has received handover floor request .
 **/
-(void)didCanceledFloorInvite:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onCanceledFloorInvite" params:Data[0]];
}

/*
  This is an event method for the all  moderator including owner of the API and participant which has received handover floor request .
**/
-(void)didRejectedInviteFloor:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onRejectedInviteFloor" params:Data[0]];
}
/*
 This is an event method for the all  moderator including owner of the API and participant which has received handover floor request .
 **/
-(void)didAcceptedFloorInvite:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onAcceptedFloorInvite" params:Data[0]];
}

/*
 Paricipant Delegates
 There would be listener for paricipant when hardunmute used by moderator. For this delegates are
 **/
-(void)didHardMuteReceived:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onReceivedHardMute" params:Data[0]];
}
/*
 Moderator Delegates
 There would be listener for moderator when hardmute used by moderator. For this delegates are
 **/
-(void)didhardMute:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onHardMuted" params:Data[0]];
}
/*
 Paricipant Delegates
 There would be listener for paricipant when hardunmute used by moderator. For this delegates are
 **/
-(void)didHardunMuteReceived:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onReceivedHardUnMute" params:Data[0]];
}
/*
 Moderator Delegates
 There would be listener for moderator when hardunmute used by moderator. For this delegates are
 **/
-(void)didhardUnMute:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onHardUnMuted" params:Data[0]];
}

/*
 This delegate called once user will set advance option and request to know about advance option update during call.
 **/

-(void)room:(EnxRoom * _Nullable)room didGetAdvanceOptions:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onGetAdvancedOptions" params:data[0]];
}
/*
 this is an acklodgment method for lockroom, whenever any moderatore will call lock room method.
 **/
-(void)room:(EnxRoom * _Nullable)room didAckLockRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckLockRoom" params:data[0]];
}
/*
 this is an acklodgment method for unlockroom, whenever any moderatore will call unlock room method.
 **/
-(void)room:(EnxRoom * _Nullable)room didAckUnlockRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckUnLockRoom" params:data[0]];
}

/*
 this delegate method will call, when moderatore will lock the room, other participent will receive this method.
 **/
-(void)room:(EnxRoom * _Nullable)room didLockRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onLockedRoom" params:data[0]];
}
/*
 this delegate method will call, when moderatore will unlock the room, other participent will receive this method.
 **/
-(void)room:(EnxRoom * _Nullable)room didUnlockRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onUnLockedRoom" params:data[0]];
}
/*
 This delegate method will called, when any of user will initiate for botbond call in same room
 **/
-(void)room:(EnxRoom * _Nullable)room didOutBoundCallInitiated:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onOutBoundCallInitiated" params:data[0]];
}


/*
 This delegate method will called, when any of user will initiate for botbond call and call state has changed.
 **/
-(void)room:(EnxRoom * _Nullable)room didDialStateEvents:(EnxOutBoundCallState)state{
    NSDictionary *dict;
    if (state == Initiated){
        dict = @{@"state":@"Initiated"};
    }
    else if (state == Ringing){
        dict = @{@"state":@"Ringing"};
    }
    else if (state == Connected){
        dict = @{@"state":@"Connected"};
    }
    else if (state == Failed){
        dict = @{@"state":@"Failed"};
    }
    else{
        dict = @{@"state":@"Disconnected"};
    }
    [self sendEvent:@"onDialStateEvents" params:dict];

}

/*
 @ This delegate method will called, when any of user will initiate for outbound call and end user will press any DTMF number

 **/
-(void)room:(EnxRoom * _Nullable)room didDTMFCollected:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onDTMFCollected" params:data[0]];
}

-(void)room:(EnxRoom * _Nullable)room didOutBoundCallCancel:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onOutBoundCallCancel" params:data[0]];
}


/*
 This delegate method will notify to the user, with cause of reconnect, reconnect can happen if network connect got disconnect or ice connection has failed etc....
 **/
-(void)room:(EnxRoom * _Nullable)room didReconnect:(NSString * _Nullable)reason{
    if(reason == nil){
        return;
    }
    [self sendEvent:@"onReconnect" params:@{@"msg":reason}];
}

/*
 This delegate method will get called when reconnect get successfully resume
 **/
-(void)room:(EnxRoom * _Nonnull)room didUserReconnectSuccess:(NSDictionary * _Nonnull)data{
    if(data == nil){
        return;
    }
    [self sendEvent:@"onUserReconnectSuccess" params:data];
}
/*
 This delegate Method Will Notify app user for any Audio media changes happen recentally(Like :- New device connected/Doisconnected).
 **/
-(void)didNotifyDeviceUpdate:(NSString * _Nonnull)updates{
    if(updates == nil){
        return;
    }
    NSDictionary *dataDict = @{@"msg":updates};
    [self sendEvent:@"onNotifyDeviceUpdate" params:dataDict];
}

/*
 all participants (Except owner of screen share) in same confrence will get this delegate method, whenever screen share has stared by any participent in same confrence.
 **/
-(void)room:(EnxRoom *_Nullable)room didScreenShareStarted:(EnxStream *_Nullable)stream{
    if(stream == nil ){
        return;
    }
    [self sendEvent:@"onScreenSharedStarted" params:@{@"result":@"0",@"streamId":(stream.streamId != nil ? stream.streamId:@"101"),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"name":(stream.name!= nil ? stream.name:@"")}];
   // [self sendEvent:@"onScreenSharedStarted" params:@{stream.streamId:stream}];
}
/*
 all participants (Except owner of screen share) in same confrence will get this delegate method, whenever screen share has stopped by any participent in same confrence.
 **/
-(void)room:(EnxRoom *_Nullable)room didScreenShareStopped:(EnxStream *_Nullable)stream{
    if(stream == nil ){
        return;
    }
    [self sendEvent:@"onScreenSharedStopped" params:@{@"result":@"0",@"streamId":(stream.streamId != nil ? stream.streamId:@"101"),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"name":(stream.name!= nil ? stream.name:@"")}];
    //[self sendEvent:@"onScreenSharedStopped" params:@{stream.streamId:stream}];
}

//
-(void)room:(EnxRoom *_Nullable)room didStartScreenShareACK:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onStartScreenShareACK" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)room didStoppedScreenShareACK:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onStoppedScreenShareACK" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)room didExitScreenShareACK:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onExitScreenShareACK" params:data[0]];
}

//#pragma mark - ACK/start/stop Annotation delegates

-(void)room:(EnxRoom *_Nullable)room didAnnotationStarted:(EnxStream *_Nullable)stream{
    if(stream == nil ){
        return;
    }
    [self sendEvent:@"onAnnotationStarted" params:@{@"result":@"0",@"streamId":(stream.streamId != nil ? stream.streamId:@"102"),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"name":(stream.name!= nil ? stream.name:@"")}];
   // [self sendEvent:@"onScreenSharedStarted" params:@{stream.streamId:stream}];
}

-(void)room:(EnxRoom *_Nullable)room didAnnotationStopped:(EnxStream *_Nullable)stream{
    if(stream == nil ){
        return;
    }
    [self sendEvent:@"onAnnotationStopped" params:@{@"result":@"0",@"streamId":(stream.streamId != nil ? stream.streamId:@"102"),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"name":(stream.name!= nil ? stream.name:@"")}];
    //[self sendEvent:@"onScreenSharedStopped" params:@{stream.streamId:stream}];
}

-(void)room:(EnxRoom *_Nullable)room didStartAnnotationACK:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onStartAnnotationAck" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)room didStoppedAnnotationACK:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onStoppedAnnotationAck" params:data[0]];
}



/*
 all participants (Except owner of start canvas) in same confrence will get this delegate method, whenever canvashas  stared by any participent in same confrence.
 **/
-(void)room:(EnxRoom *_Nullable)room didCanvasStarted:(EnxStream *_Nullable)stream{
    if(stream == nil ){
        return;
    }
    [self sendEvent:@"onCanvasStarted" params:@{@"result":@"0",@"streamId":(stream.streamId != nil ? stream.streamId:@"102"),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"name":(stream.name!= nil ? stream.name:@"")}];
    //[self sendEvent:@"onCanvasStarted" params:@{stream.streamId:stream}];
}
/*
 all participants (Except owner of stop canvas) in same confrence will get this delegate method, whenever canvas has stopped by any participent in same confrence
 **/
-(void)room:(EnxRoom *_Nullable)room didCanvasStopped:(EnxStream *_Nullable)stream{
    if(stream == nil){
        return;
    }
    [self sendEvent:@"onCanvasStopped" params:@{@"result":@"0",@"streamId":(stream.streamId != nil ? stream.streamId:@"102"),@"clientId":(stream.clientId!= nil ? stream.clientId:@""),@"name":(stream.name!= nil ? stream.name:@"")}];
    //[self sendEvent:@"onCanvasStopped" params:@{stream.streamId:stream}];
}



/*
 this delegate method will get called when request for stats and stats receive in room
 **/

-(void)didReceiveStats:(NSArray * _Nonnull)statsData{
    if(statsData == nil || statsData.count == 0){
           return;
    }
    [self sendEvent:@"onReceiveStats" params:statsData[0]];
}
/*
 This is an acknowledgment delegate method for send data, when any of participent will send their data to other participent
 **/
-(void)room:(EnxRoom * _Nullable)room didAcknowledgSendData:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onAckSendData" params:data[0]];
}
/*
 This delegate method called When any of the user in same room will start sharing file
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileUploadStarted:(NSArray * _Nullable)data{
     if(data == nil || data.count == 0){
            return;
     }
     [self sendEvent:@"onFileUploadStarted" params:data[0]];
}
/*
 This delegate method called When any user will share file successfully and now File available to download for other participent.
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileAvailable:(NSArray * _Nullable)data{
     if(data == nil || data.count == 0){
            return;
     }
     [self sendEvent:@"onFileAvailable" params:data[0]];
}
/*
 This delegate method called When self user will start sharing file
 **/
-(void)room:(EnxRoom * _Nonnull)room didInitFileUpload:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onInitFileUpload" params:data[0]];
}
/*
 This delegate method called upload file is success.
 **/

-(void)room:(EnxRoom * _Nonnull)room didFileUploaded:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onFileUploaded" params:data[0]];
}
/*
 This delegate method called When file Upload Cancel.
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileUploadCancelled:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onFileUploadCancelled" params:data[0]];
}
/*
 This delegate method called upload file is failed.
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileUploadFailed:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onFileUploadFailed" params:data[0]];
}

/*
 This delegate method called When download of file success.
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileDownloaded:(NSString * _Nullable)data{
    if(data == nil){
           return;
    }
    [self sendEvent:@"onFileDownloaded" params:@{@"msg":data}];
}
/*
 This delegate method called When file download Cancel.
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileDownloadCancelled:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onFileDownloadCancelled" params:data[0]];
}
/*
 This delegate method called When file download failed.
 **/
-(void)room:(EnxRoom * _Nonnull)room didFileDownloadFailed:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onFileDownloadFailed" params:data[0]];
}
/*
 This delegate method called When file download initiated.
 **/
-(void)room:(EnxRoom * _Nonnull)room didInitFileDownload:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
    }
    [self sendEvent:@"onInitFileDownload" params:data[0]];
}
/*
 This delegate method will notify to all available modiatore, Once any participent has cancled there floor request
 **/
-(void)didCancelledFloorRequest:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
           return;
    }
    [self sendEvent:@"onCancelledFloorRequest" params:Data[0]];
}
/*
 This ACK method for Participent only, When he/she will cancle their request floor
 **/
-(void)didFloorCancelled:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
           return;
    }
    [self sendEvent:@"onFloorCancelled" params:Data[0]];
}
/*
 This delegate method will notify to all available modiatore, Once any participent has finished there floor request
 **/
-(void)didFinishedFloorRequest:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
           return;
    }
    [self sendEvent:@"onFinishedFloorRequest" params:Data[0]];
}
/*
 This ACK method for Participent , When he/she will finished their request floor
 after request floor accepted by any modiatore
 **/
-(void)didFloorFinished:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
           return;
    }
    [self sendEvent:@"onFloorFinished" params:Data[0]];
}


#pragma mark - EnxRTCiOS_Stream Delegate
/*
 Fired when audio self mute/unmute events call on EnxStream object.
 **/
-(void)didAudioEvents:(NSDictionary * _Nullable)data{
    if(data == nil){
        return;
    }
    [self sendEvent:@"onAudioEvent" params:data];
}
/*
 Fired when video self On/Off events call on EnxStream object.
 **/
-(void)didVideoEvents:(NSDictionary * _Nullable)data{
    if(data == nil){
        return;
    }
    [self sendEvent:@"onVideoEvent" params:data];
}
/*
 Fired when a data stream is received.
 **/
-(void)didReceiveData:(NSDictionary * _Nullable)data{
    if(data == nil){
        return;
    }
    [self sendEvent:@"onReceivedData" params:data];
}
/*
 Fired when a self mute audio alert participant received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didRemoteStreamAudioMute:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRemoteStreamAudioMute" params:data[0]];
}
/*
 Fired when a self unmute audio alert participant received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didRemoteStreamAudioUnMute:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRemoteStreamAudioUnMute" params:data[0]];
}
/*
 Fired when a self mute video alert participant received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didRemoteStreamVideoMute:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRemoteStreamVideoMute" params:data[0]];
}
/*
 Fired when a self unmute video alert participant received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didRemoteStreamVideoUnMute:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRemoteStreamVideoUnMute" params:data[0]];
}
/*There would be listener for moderator when hardmute used by moderator. For this delegates are:
 Moderator Delegates**/

-(void)didhardMuteAudio:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onHardMutedAudio" params:Data[0]];
}
/**
 There would be listener for moderator when hardmute done by moderator. For this delegates are:
 Moderator Delegates*/
-(void)didhardUnMuteAudio:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onHardUnMutedAudio" params:Data[0]];
}
/**
 There would be listener for Paricipant when hardmute used by moderator. this delegates is a
 Paricipant Delegate */
-(void)didRecievedHardMutedAudio:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onReceivedHardMuteAudio" params:Data[0]];
}
/**
 There would be listener for Paricipant when hard unmute done by moderator. this delegates is a
 Paricipant Delegate */
-(void)didRecievedHardUnmutedAudio:(NSArray * _Nullable)Data{
    if(Data == nil || Data.count == 0){
        return;
    }
    [self sendEvent:@"onReceivedHardUnMuteAudio" params:Data[0]];
}
/*
 Fired when a hard mute video alert moderator received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didHardVideoMute:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onHardMutedVideo" params:data[0]];
}
/*
 Fired when a hard unmute video alert moderator received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didHardVideoUnMute:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onHardUnMutedVideo" params:data[0]];
}
/*
 Fired when a hard mute video alert participant received from server.
 **/
-(void)stream:(EnxStream * _Nullable)stream didReceivehardMuteVideo:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onReceivedHardMuteVideo" params:data[0]];
}
/**
 Fired when a hard unmute video alert participant received from server.*/
-(void)stream:(EnxStream * _Nullable)stream didRecivehardUnmuteVideo:(NSArray * _Nullable)data{
     if(data == nil || data.count == 0){
         return;
     }
     [self sendEvent:@"onReceivedHardUnMuteVideo" params:data[0]];
}

//Player Delegate

/*
 To get thesnap shot for the individual player , User need to set EnxPlayerDelegate player delegates and listen their -didCapturedView:  call back method. didCapturedView: will keep notify about snapshot image whenever user demand.
 **/
-(void)didCapturedView:(UIImage * _Nonnull)snapShot{
    if(snapShot != nil){
     NSData *imageData = UIImagePNGRepresentation(snapShot);
     NSString * base64String = [imageData base64EncodedStringWithOptions:0];
     if(base64String != nil){
         [self sendEvent:@"OnCapturedView" params:@{@"bitmap":base64String}];
     }
    }
}

//Pin Delegates
/*
 this is an acknowledgment method for pinUser events done by any modiatore.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckPinUsers:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
       }
       [self sendEvent:@"onAckPinUsers" params:data[0]];
}
/*
 this is an acknowledgment method for UnpinUsers events done by any modiatore.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckUnpinUsers:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckUnpinUsers" params:data[0]];
}
/*
 this delegate method will update the list of pinned user list in same confrence.
 **/
-(void)room:(EnxRoom * _Nullable)channel didPinnedUsers:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onPinnedUsers" params:data[0]];
}

/**
   delegate   Knock-Knock Room /wait for moderator
   */
/*this delegate method will inform to a participent , who is going to join a knock-knock room or wait for moderatore enable room.
This API will inform either its knock-knoc room or wait for moderatore room.
This API only for participent.
*/
   -(void)room:(EnxRoom * _Nullable)channel didRoomAwated:(NSArray * _Nullable)data{
       if(data == nil || data.count == 0){
           return;
       }
       [self sendEvent:@"onRoomAwaited" params:data[0]];
   }
/*
 this acknowledgment method for modeator, when  he/she will approved awated user in knock knock room.
 **/
    -(void)room:(EnxRoom * _Nullable)channel didAckForApproveAwaitedUser:(NSArray * _Nullable)data{
          if(data == nil || data.count == 0){
              return;
          }
          [self sendEvent:@"onAckForApproveAwaitedUser" params:data[0]];
      }
/*
 this acknowledgment method for modeator, when he/she will deny  awated user in knock knock room.
 **/
    -(void)room:(EnxRoom * _Nullable)channel didAckForDenyAwaitedUser:(NSArray * _Nullable)data{
             if(data == nil || data.count == 0){
                 return;
             }
             [self sendEvent:@"onAckForDenyAwaitedUser" params:data[0]];
         }
/*
 this callback method for modeartor , when any user user join after modeartor join and waiting in lobby.
 **/
   -(void)room:(EnxRoom * _Nullable)channel diduserAwaited:(NSArray * _Nullable)data{
                if(data == nil || data.count == 0){
                    return;
                }
                [self sendEvent:@"onUserAwaited" params:data[0]];
            }





/**
  delegate  Talker notification
 */
/*This delegate called for Talker notification subscribe
 */

-(void)room:(EnxRoom * _Nullable)channel didAckSubscribeTalkerNotification:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckSubscribeTalkerNotification" params:data[0]];
}
/*
 This delegate called for Talker notification unsubscribe updates.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckUnsubscribeTalkerNotification:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckUnsubscribeTalkerNotification" params:data[0]];
}
/*
 This delegate called for Talker notification subscribe/unsubscribeupdates.
 **/
-(void)room:(EnxRoom * _Nullable)channel didTalkerNotification:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onTalkerNotification" params:data[0]];
}

//pragma mark - BreakOut Room Delegates
/*
 this is an acklodgment method for create breakout  room, Moderatore/Participent can create a breakout room at any time in running confrence.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckCreateBreakOutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckCreateBreakOutRoom" params:data[0]];
}
/*
 this is an acklodgment method for create room, Moderatore/Participent can create and invite a breakout room at any time in running confrence
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckCreateAndInviteBreakOutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckCreateAndInviteBreakOutRoom" params:data[0]];
}
/*
 this delegate method will called when any user will try to join breakout room and failed.
 **/
-(void)room:(EnxRoom * _Nullable)channel didFailedJoinBreakOutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onFailedJoinBreakOutRoom" params:data[0]];
}
/*
 this is an acklodgment method for invite brealout room, Moderatore/Participent can intite to any user to join any breakout room.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckInviteBreakOutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckInviteBreakOutRoom" params:data[0]];
}
/*
this delegate method will called, when user joined breakout room successfully.*/

-(void)room:(EnxRoom * _Nullable)channel didConnectedBreakoutRoom:(NSDictionary * _Nullable)roomMetadata{
    if(roomMetadata == nil ){
        return;
    }
    [self sendEvent:@"onConnectedBreakoutRoom" params:roomMetadata];
}

/*This delegate method will called, when user will disconnected from breakout room either self or due to any cause.
 */
-(void)room:(EnxRoom * _Nullable)channel didDisconnectedBreakoutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onDisconnectedBreakoutRoom" params:data[0]];
}
/*
 This delegate method will called, when user will joined any breakout room.
 **/
-(void)room:(EnxRoom * _Nullable)channel didUserJoinedBreakoutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onUserJoinedBreakoutRoom" params:data[0]];
}
/*
 This delegate method will called, when user will joined any breakout room.
 **/
-(void)room:(EnxRoom * _Nullable)channel didInvitationForBreakoutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onInvitationForBreakoutRoom" params:data[0]];
}
/*
 this is the Room on listrener method, Which will inform to owner of breakout room that all user has disconencted and room get destroied.
 */
-(void)room:(EnxRoom * _Nullable)channel didDestroyedBreakoutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onDestroyedBreakoutRoom" params:data[0]];
}
/*
 this is the socket on listrener method for all use in parents room will get notify about user disconnected from breakout room resently.
 **/
-(void)room:(EnxRoom * _Nullable)channel didUserDisconnectedFromBreakoutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onUserDisconnectedFromBreakoutRoom" params:data[0]];
}


/*
  @details this is the socket emit acknowledgment listrener method for the user who has rejected to join breakout room.
**/
-(void)room:(EnxRoom * _Nullable)channel didAckRejectBreakoutRoom:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckRejectBreakoutRoom" params:data[0]];
}
/*
 @details this is the socket on room managment listrener method for all moderator , once breakout room created.
  **/
-(void)room:(EnxRoom * _Nullable)channel didBreakoutRoomCreated:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onBreakoutRoomCreated" params:data[0]];
}


/*
@details this is the socket on room managment listrener method, will be sent to all the moderators about a participant being invited to breakout room
   **/
-(void)room:(EnxRoom * _Nullable)channel didBreakoutRoomInvited:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onBreakoutRoomInvited" params:data[0]];
}

/*
@details this is the socket on room managment listrener method, event will be sent to the invitee and all the moderator if the breakout invite is rejected. The message will contain the room_id and rejected client id.
  **/
-(void)room:(EnxRoom * _Nullable)channel didBreakoutRoomInviteRejected:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onBreakoutRoomInviteRejected" params:data[0]];
}



//SpotLightUser Delegates
/*
 this is an acknowledgment method for  add Spotlight events  events done by any modrator.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckAddSpotlightUsers:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
           return;
       }
       [self sendEvent:@"onAckAddSpotlightUsers" params:data[0]];
}
/*
@details this is an acknowledgment method for remove Spotlight events done by any moderator.
 **/
-(void)room:(EnxRoom * _Nullable)channel didAckRemoveSpotlightUsers:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckRemoveSpotlightUsers" params:data[0]];
}
/*
 @details this delegate method will update the list of Spotlight user list in same confrence.
 **/
-(void)room:(EnxRoom * _Nullable)channel didUpdatedSpotlightUsers:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onUpdateSpotlightUsers" params:data[0]];
}
/*
@details This delegate notify to the user incase of subscriber bandwidth goes low
 **/
-(void)room:(EnxRoom * _Nullable)channel didRoomBandwidthAlert:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomBandwidthAlert" params:data[0]];
}

#pragma mark- TrubleShooter callback
-(void)didClientDiagnosisFinished:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onClientDiagnosisFinished" params:data[0]];
}
-(void)didClientDiagnosisFailed:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onClientDiagnosisFailed" params:data[0]];
}
-(void)didClientDiagnosisStatus:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onClientDiagnosisStatus" params:data[0]];
}
-(void)didClientDiagnosisStopped:(NSArray * _Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onClientDiagnosisStopped" params:data[0]];
}

#pragma mark- SwitchRoom  callback
-(void)room:(EnxRoom *_Nullable)channel didAckSwitchedRoom:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckSwitchedRoom" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)channel didRoomModeSwitched:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomModeSwitched" params:data[0]];
}
#pragma mark- Live Streaming  callback
-(void)room:(EnxRoom *_Nullable)channel didAckStartStreaming:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckStartStreaming" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)channel didAckStopStreaming:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckStopStreaming" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)channel didStreamingStarted:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onStreamingStarted" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)channel didStreamingStopped:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onStreamingStopped" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)channel didStreamingFailed:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onStreamingFailed" params:data[0]];
}
-(void)room:(EnxRoom *_Nullable)channel didStreamingUpdated:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onStreamingUpdated" params:data[0]];
}
//Live Recording callbacks
-(void)room:(EnxRoom* _Nullable)room didACKStartLiveRecording:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    NSDictionary *dict = nil;
    if([data[0] isKindOfClass:[NSDictionary class]]){
        dict = data[0];
    }
    else{
        dict = data[1];
    }
    [self sendEvent:@"onACKStartLiveRecording" params:dict];
}
-(void)room:(EnxRoom* _Nullable)room didRoomLiveRecordingOn:(NSArray *_Nullable)data{
   if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomLiveRecordingOn" params:data[0]];
}
-(void)room:(EnxRoom* _Nullable)room didRoomLiveRecordingOff:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomLiveRecordingOff" params:data[0]];
}
-(void)room:(EnxRoom* _Nullable)room didRoomLiveRecordingFailed:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomLiveRecordingFailed" params:data[0]];
}
-(void)room:(EnxRoom* _Nullable)room didRoomLiveRecordingUpdated:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomLiveRecordingUpdate" params:data[0]];
}

-(void)room:(EnxRoom* _Nullable)room didACKStopLiveRecording:(NSArray *_Nullable)data{
    if(data == nil || data.count == 0){
        return;
    }
    NSDictionary *dict = nil;
        if([data[0] isKindOfClass:[NSDictionary class]]){
            dict = data[0];
        }
        else{
            dict = data[1];
        }
    [self sendEvent:@"onACKStopLiveRecording" params:dict];
}

-(void)room:(EnxRoom* _Nullable)room didAckHardMuteUserAudio:(NSArray *_Nullable)data{
   if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckHardMuteUserAudio" params:data[0]];
}
-(void)room:(EnxRoom* _Nullable)room didAckHardunMuteUserAudio:(NSArray *_Nullable)data{
   if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckHardunMuteUserAudio" params:data[0]];
}
-(void)room:(EnxRoom* _Nullable)room didAckHardMuteUserVideo:(NSArray *_Nullable)data{
   if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckHardMuteUserVideo" params:data[0]];
}
-(void)room:(EnxRoom* _Nullable)room didAckHardUnMuteUserVideo:(NSArray *_Nullable)data{
   if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onAckHardUnMuteUserVideo" params:data[0]];
}
//
- (void)room:(EnxRoom* _Nullable)room didACKStartLiveTranscription:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onACKStartLiveTranscription" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didACKStopLiveTranscription:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onACKStopLiveTranscription" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didTranscriptionEvents:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onTranscriptionEvents" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didRoomTranscriptionOn:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomTranscriptionOn" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didRoomTranscriptionOff:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onRoomTranscriptionOff" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didSelfTranscriptionOn:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onSelfTranscriptionOn" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didSelfTranscriptionOff:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onSelfTranscriptionOff" params:data[0]];
}
//
- (void)room:(EnxRoom* _Nullable)room didHlsStarted:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onHlsStarted" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didHlsStopped:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onHlsStopped" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didHlsFailed:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onHlsFailed" params:data[0]];
}
- (void)room:(EnxRoom* _Nullable)room didHlsWaiting:(NSArray *_Nonnull)data{
 if(data == nil || data.count == 0){
        return;
    }
    [self sendEvent:@"onHlsWaiting" params:data[0]];
}

//


//remove all instance
-(void)releaseObjects{
    if (_methodChannel != nil){
        _methodChannel = nil;
    }
    if (_eventChannel != nil){
        _eventChannel = nil;
    }
    if (_eventSink != nil){
        _eventSink = nil;
    }
    if (_enxRoom != nil){
        _enxRoom = nil;
    }
    if (_enxRTc != nil){
        _enxRTc = nil;
    }
    if (_localStream != nil){
        _localStream = nil;
    }
    if (_rendererViews != nil){
        _rendererViews = nil;
    }
   // if (_playerViews != nil){
     //   _playerViews = nil;
   // }
    if (_streamDictionary != nil){
        _streamDictionary = nil;
    }
}

@end

@implementation EnxRenderViewFactory
- (nonnull NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    NSLog(@"viewIdddd:  %lld",viewId);
    EnxPlayer *rendererView = [[EnxPlayer alloc] initWithFrame:frame viewIdentifier:viewId];
  //  [rendererView.view setBackgroundColor:[UIColor redColor]];
     
    [EnxFlutterPlugin addView:rendererView.view id:@(viewId)];

    return rendererView;
}

@end


@implementation EnxToolbarRenderViewFactory

- (nonnull NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:args{
    NSLog(@"viewIdddd:  %lld",viewId);
    NSLog(@"arg:  %@",args);
 
    EnxToolbarView *rendererView = [[EnxToolbarView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args];
  //  [rendererView.view setBackgroundColor:[UIColor redColor]];

    [EnxFlutterPlugin addView:rendererView.view id:@(viewId)];

    return rendererView;
}


@end



