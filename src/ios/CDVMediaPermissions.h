#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>

@interface CDVMediaPermissions : CDVPlugin

- (void) check:(CDVInvokedUrlCommand*)command;
- (void) request:(CDVInvokedUrlCommand*)command;

@end
