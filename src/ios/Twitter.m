#import "Twitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Cordova/CDV.h>

@implementation Twitter

+ (BOOL)userHasAccessToTwitter
{
	return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)requestAccess:(CDVInvokedUrlCommand*)command
{
	NSLog(@"TWITTER: requestAccess");
	ACAccountStore* accountStore = [[ACAccountStore alloc] init];
	ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[accountStore requestAccessToAccountsWithType:twitterAccountType
	              options:NULL
	              completion:^(BOOL granted, NSError* error){}];
}

- (void)accountExists:(CDVInvokedUrlCommand*)command
{
	NSLog(@"TWITTER: userExists");
	NSString* myName = [command argumentAtIndex:0];
	__block CDVPluginResult* pluginResult = nil;

	ACAccountStore* accountStore = [[ACAccountStore alloc] init];
	ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

	[accountStore requestAccessToAccountsWithType:twitterAccountType
	              options:NULL
	              completion:^(BOOL granted, NSError* error) {
		if (granted) {
			NSArray* twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
			NSUInteger accountIndex = [twitterAccounts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
				ACAccount* acc = (ACAccount*)obj;
				if ([myName isEqualToString:acc.username]){
					*stop = YES;
					return true;
				}
				return NO;
			}];
			if (accountIndex == NSNotFound){
				pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
				                                messageAsString:@"Not found"];
			}
			else{
				pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
			}
			[self.commandDelegate sendPluginResult:pluginResult
			                      callbackId:command.callbackId];
		}
		else {
			NSLog(@"Error: %@", error);
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
			                                messageAsString:@"Access denied"];
			[self.commandDelegate sendPluginResult:pluginResult
			                      callbackId:command.callbackId];
		}
	}];
}

- (void)listAccounts:(CDVInvokedUrlCommand*)command
{
	NSLog(@"TWITTER: listAccounts");
	__block CDVPluginResult* pluginResult = nil;

	ACAccountStore* accountStore = [[ACAccountStore alloc] init];
	ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

	[accountStore requestAccessToAccountsWithType:twitterAccountType
	              options:NULL
	              completion:^(BOOL granted, NSError* error) {
		if (granted) {
			NSArray* twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
			NSMutableArray* usernamesMut = [NSMutableArray array];
			for (int i=0; i<[twitterAccounts count]; ++i){
				ACAccount* a = [twitterAccounts objectAtIndex:i];
				[usernamesMut addObject:a.username];
			}
			NSArray* usernames = [usernamesMut copy];
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
			                                messageAsArray:usernames];
		}
		else {
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
			                                messageAsString:@"Access denied"];
		}
		[self.commandDelegate sendPluginResult:pluginResult
		                      callbackId:command.callbackId];
	}];
}

- (void)sendDirectMessage:(CDVInvokedUrlCommand*)command
{
	NSLog(@"TWITTER: sendDirectMessage");
	ACAccountStore* accountStore = [[ACAccountStore alloc] init];
	__block CDVPluginResult* pluginResult = nil;
	NSString* myName = [command argumentAtIndex:0];
	NSString* targetName = [command argumentAtIndex:1];
	NSString* message = [command argumentAtIndex:2];

	ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[accountStore requestAccessToAccountsWithType:twitterAccountType
	              options:NULL
	              completion:^(BOOL granted, NSError* error) {
		if (granted) {
			NSArray* twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
			NSURL* url = [NSURL URLWithString:@"https://api.twitter.com" @"/1.1/direct_messages/new.json"];
			NSDictionary* params = @{@"screen_name":targetName, @"text":message};
			SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeTwitter
			                                requestMethod:SLRequestMethodPOST
			                                URL:url
			                                parameters:params];

			NSUInteger accountIndex = [twitterAccounts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
				ACAccount* acc = (ACAccount*)obj;
				if ([myName isEqualToString:acc.username]){
					*stop = YES;
					return true;
				}
				return NO;
			}];
			if (accountIndex == NSNotFound || accountIndex >= [twitterAccounts count]){
				// nope
				pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
				                                messageAsString:@"Account not found"];
				[self.commandDelegate sendPluginResult:pluginResult
				                      callbackId:command.callbackId];
				return;
			}

			[request setAccount:[twitterAccounts objectAtIndex:accountIndex]];

			[request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
				if (responseData) {
					if (urlResponse.statusCode >= 200 &&
						urlResponse.statusCode < 300) {

						NSError* jsonError;
						NSDictionary* timelineData = [NSJSONSerialization JSONObjectWithData:responseData
						                                                  options:NSJSONReadingAllowFragments
						                                                  error:&jsonError];
						if (timelineData) {
							NSLog(@"Timeline Response: %@\n", timelineData);
							pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
						}
						else {
							NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
							pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
							                                messageAsString:@"JSON Error"];
						}
					}
					else {
						NSLog(@"The response status code is %d", urlResponse.statusCode);
						pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
						                                messageAsString:@"Error code 403"];
					}
					[self.commandDelegate sendPluginResult:pluginResult
					                      callbackId:command.callbackId];
				}
			}];
		}
		else {
			NSLog(@"Error: %@", error);
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
			                                messageAsString:@"Account permission not granted"];
			[self.commandDelegate sendPluginResult:pluginResult
			                      callbackId:command.callbackId];
		}
	}];
}

@end
