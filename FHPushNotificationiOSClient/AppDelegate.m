#import "AppDelegate.h"
#import <AeroGear-Push/AeroGearPush.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // when running under iOS 8 we will use the new API for APNS registration
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Is the app alreday registered for some sport categories
    NSMutableArray* subscribedCategories =  [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscribedCategories"]];
    // initialize "Registration helper" object using the
    // base URL where the "AeroGear Unified Push Server" is running.
    NSString* serverURL =@"<# URL of the running AeroGear UnifiedPush Server #>";
    
    AGDeviceRegistration *registration = [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString: serverURL]];
    
    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        // You need to fill the 'Variant Id' together with the 'Variant Secret'
        // both received when performing the variant registration with the server.
        NSString* variantID = @"<# Variant Id #>";
        NSString* variantSecret = @"<# Variant Secret #>";
        [clientInfo setVariantID: variantID];
        [clientInfo setVariantSecret: variantSecret];
        
        // if the deviceToken value is nil, no registration will be performed
        // and the failure callback is being invoked!
        [clientInfo setDeviceToken:deviceToken];
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"deviceToken"];
        [[NSUserDefaults standardUserDefaults] setObject:variantID forKey:@"variantID"];
        [[NSUserDefaults standardUserDefaults] setObject:variantSecret forKey:@"variantSecret"];
        [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:@"serverURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // apply the token, to identify THIS device
        UIDevice *currentDevice = [UIDevice currentDevice];
        
        // --optional config--
        // set some 'useful' hardware information params
        [clientInfo setOperatingSystem:[currentDevice systemName]];
        [clientInfo setOsVersion:[currentDevice systemVersion]];
        [clientInfo setDeviceType: [currentDevice model]];
        [clientInfo setCategories: subscribedCategories];
        
    } success:^() {
        NSLog(@"Unified Push registration successful");
        
    } failure:^(NSError *error) {
        NSLog(@"Unified Push registration Error: %@", error);
    }];
}

// Callback called after failing to register with APNS
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unified Push registration Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // When a message is received, send NSNotification, will be handle by registered AGViewController
    NSNotification *notification = [NSNotification notificationWithName:@"message_received" object:[self pushMessageContent:userInfo]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    NSLog(@"UPS message received: %@", userInfo);
}

- (NSString*)pushMessageContent:(NSDictionary *)userInfo {
    NSString* content;
    if ([userInfo[@"aps"][@"alert"] isKindOfClass:[NSString class]]) {
        content = userInfo[@"aps"][@"alert"];
    } else {
        content = userInfo[@"aps"][@"alert"][@"body"];
    }
    return content;
}

@end
