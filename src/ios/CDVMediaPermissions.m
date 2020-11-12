#import <objc/runtime.h>
#import <Cordova/CDVViewController.h>
#import <AVFoundation/AVFoundation.h>

#import "CDVMediaPermissions.h"

@implementation CDVMediaPermissions

- (void)pluginInitialize {}

- (void) check:(CDVInvokedUrlCommand*)command {
    NSString *_checkCallbackId = command.callbackId;
    NSNumber *microphone = @NO;
    NSNumber *camera = @NO;

    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission sessionRecordPermission = [session recordPermission];

    if(sessionRecordPermission == AVAudioSessionRecordPermissionGranted) {
        microphone = @YES;
    }

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus cameraPermission = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    if(cameraPermission == AVAuthorizationStatusAuthorized) {
        camera = @YES;
    }

    NSDictionary* payload = @{
        @"microphone": microphone,
        @"camera": camera
    };
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
    [self.commandDelegate sendPluginResult:result callbackId:_checkCallbackId];
}

- (void) request:(CDVInvokedUrlCommand*)command {
    NSLog(@"Check and request microphone permission");

    [self.commandDelegate runInBackground:^{
        AVAudioSession *session = [AVAudioSession sharedInstance];
        AVAudioSessionRecordPermission sessionRecordPermission = [session recordPermission];

        if(sessionRecordPermission == AVAudioSessionRecordPermissionUndetermined) {

            NSLog(@"Microphone permission unknown - trigger prompt");
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {

                if (granted) {
                    NSLog(@"Microphone permission granted");
                    [self askCameraPermission:command];
                } else {
                    NSLog(@"Microphone permission denied");
                    [self returnPermissionDenied:command];
                }
            }];
        }

        if(sessionRecordPermission == AVAudioSessionRecordPermissionDenied) {
            NSLog(@"Microphone permission denied");
            [self returnPermissionDenied:command];
        }

        if(sessionRecordPermission == AVAudioSessionRecordPermissionGranted) {
            NSLog(@"Microphone permission granted");
            [self askCameraPermission:command];
        }
    }];
}

- (void) askCameraPermission:(CDVInvokedUrlCommand *) command{

    NSLog(@"Check and request camera permission");

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus cameraPermission = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    if(cameraPermission == AVAuthorizationStatusNotDetermined){

        NSLog(@"Camera permission unknow - trigger prompt");

        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{

                if(granted) {
                    NSLog(@"Camera permission granted");
                    [self returnAllPermissionGranted:command];
                } else {
                    NSLog(@"Camera permission denied");
                    [self returnPermissionDenied:command];
                }
            });
        }];
    }

    if(cameraPermission == AVAuthorizationStatusDenied){
        NSLog(@"Camera permission denied");
        [self returnPermissionDenied:command];
    }

    if(cameraPermission == AVAuthorizationStatusAuthorized){
        NSLog(@"Camera permission granted");
        [self returnAllPermissionGranted:command];
    }
}

- (void) returnAllPermissionGranted:(CDVInvokedUrlCommand *) command{

    NSLog(@"All permissions granted");
    NSDictionary* payload = @{
        @"microphone": @YES,
        @"camera": @YES
    };
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)returnPermissionDenied:(CDVInvokedUrlCommand *) command
{
    NSLog(@"Permission denied - Return error message");
    NSDictionary* payload = @{@"error": @"permission-denied"};
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:payload];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


@end
