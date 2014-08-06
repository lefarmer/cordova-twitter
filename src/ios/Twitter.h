#import <Cordova/CDVPlugin.h>

@interface Twitter : CDVPlugin

- (void)requestAccess:(CDVInvokedUrlCommand*)command;
- (void)accountExists:(CDVInvokedUrlCommand*)command;
- (void)listAccounts:(CDVInvokedUrlCommand*)command;
- (void)sendDirectMessage:(CDVInvokedUrlCommand*)command;

@end
