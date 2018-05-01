#import "RCTOkkamiSdk.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation OkkamiSdk

// define macro
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SMOOCH_NAME @"OKKAMI CONCIERGE"
#define OKKAMI_DEEPLINK @"okkami://"

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

-(id)init {
    if ( self = [super init] ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.isSmoochShow = NO;
        self.isCheckNotif = NO;
        self.currentSmoochToken = @"";
        self.hotelName = SMOOCH_NAME;
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestWhenInUseAuthorization];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.appdel = appDelegate;
        
        /*if (!self.appdel.isOkkami) {
            RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
            self.main = main;
            //[self registerInstanceId:self.appdel.pusher_instance_id];
        }*/
    }
    return self;
}

- (void)deletePList: (NSString*)plistname {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plistname]];
        NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        
    }
}


- (void)openSmooch: (NSString*)appToken userId:(NSString*)userId title:(NSString*)title {
    [Smooch destroy];
    if([title isEqualToString:@""] || title == nil){
        self.hotelName = SMOOCH_NAME;
    }else{
        self.hotelName = title;
    }
    self.currentSmoochToken = appToken;
    SKTSettings *settings = [SKTSettings settingsWithAppId:appToken];
    settings.enableAppDelegateSwizzling = NO;
    settings.enableUserNotificationCenterDelegateOverride = NO;
    [Smooch initWithSettings:settings completionHandler:nil];
    [[Smooch conversation] setDelegate:self];
    [Smooch login:self.smoochUserId jwt:self.smoochUserJwt completionHandler:nil];
    [Smooch show];
}


- (void)handleOkkamiUrlWithDeepLink: (NSString*)url title: (NSString*)title {
    NSString *preTel;
    NSString *postTel;
    NSScanner *scanner = [NSScanner scannerWithString:url];
    [scanner scanUpToString:OKKAMI_DEEPLINK intoString:&preTel];
    [scanner scanString:OKKAMI_DEEPLINK intoString:nil];
    postTel = [url substringFromIndex:scanner.scanLocation];
    [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_WEBVIEW" body:@{@"hotelName":self.hotelName,@"title":title,@"url":postTel,@"appToken": self.currentSmoochToken, @"smooch_user_jwt":self.smoochUserJwt}];
    [self.currentViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)handleOkkamiUrl: (NSString*)url title: (NSString*)title {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([url containsString:[NSString stringWithFormat:@"%@://", appDelegate.okkamiDeepLink]]) {
        [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_SCREEN" body:@{@"screen":url}];
    } else {
        [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_WEBVIEW" body:@{@"hotelName":self.hotelName,@"title":title,@"url":url,@"appToken": self.currentSmoochToken, @"user_id":self.smoochUserId, @"smooch_user_jwt":self.smoochUserJwt}];
    }
    [self.currentViewController dismissViewControllerAnimated:true completion:nil];
}


- (void)sendEvent: (NSString*)eventName :(NSDictionary*)eventBody {
    [self.bridge.eventDispatcher sendAppEventWithName:eventName body:eventBody];
}

#pragma mark Smooch Delegate

-(BOOL)conversation:(SKTConversation *)conversation shouldShowInAppNotificationForMessage:(SKTMessage *)message{
    return NO;
}

-(void)conversation:(SKTConversation *)conversation willShowViewController:(UIViewController *)viewController{
    viewController.navigationItem.title = self.hotelName;
    self.currentViewController = viewController;
    self.isSmoochShow = YES;
}

-(void)conversation:(SKTConversation *)conversation didShowViewController:(UIViewController *)viewController{
    if(self.isCheckNotif){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

-(void)conversation:(SKTConversation *)conversation willDismissViewController:(UIViewController *)viewController{
    self.isSmoochShow = NO;
}

-(void)conversation:(SKTConversation *)conversation didDismissViewController:(UIViewController *)viewController{
    if(self.isCheckNotif){
        self.isCheckNotif = NO;
    }
    [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
}

- (BOOL)conversation:(SKTConversation *)conversation shouldHandleMessageAction:(SKTMessageAction *)action{
    if(action.uri != nil && [action.type isEqualToString:@"link"]){
        if([[NSString stringWithFormat:@"%@", action.uri] containsString:@"maps.google"]){
            return YES;
        }else{
            [self handleOkkamiUrl:action.uri.absoluteString title:action.text];
            return NO;
        }
    }
    return YES;
}

- (NSString *)HMACSHA1:(NSData *)data secret:(NSString *)secret{
    NSParameterAssert(data);
    
    NSData *keyData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *hMacOut = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1,
           keyData.bytes, keyData.length,
           data.bytes,    data.length,
           hMacOut.mutableBytes);
    
    NSString *hexString = @"";
    if (data) {
        uint8_t *dataPointer = (uint8_t *)(hMacOut.bytes);
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            hexString = [hexString stringByAppendingFormat:@"%02x", dataPointer[i]];
        }
    }
    
    return hexString;
}

#pragma mark Pusher Delegate
-(void) pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel{

}

-(void) pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel{

}

-(void) nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId{
    
}

-(void) nativePusher:(PTNativePusher *)nativePusher didSubscribeToInterest:(NSString *)interestName{

}

-(void) nativePusher:(PTNativePusher *)nativePusher didUnsubscribeFromInterest:(NSString *)interestName{

}

#pragma mark Notif Delegate

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Smooch logoutWithCompletionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
       [Smooch destroy];
    }];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appdel = appDelegate;
    [[self.appdel.pusher nativePusher] registerWithDeviceToken:deviceToken];

    /*if (!self.appdel.isOkkami) {
        [self registerForPusher:deviceToken];
    } else {        
        [[self.appdel.pusher nativePusher] registerWithDeviceToken:deviceToken];
    }*/
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [Smooch logoutWithCompletionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        [Smooch destroy];
    }];
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void
                                                                                                                               (^)(UIBackgroundFetchResult))completionHandler
{
    [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:userInfo[@"data"]];
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
        return;
    }
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:userInfo[@"data"]];
        if([userInfo[@"aps"][@"alert"][@"title"] isEqualToString:@""] || userInfo[@"aps"][@"alert"][@"title"] == nil){
            self.hotelName = SMOOCH_NAME;
        }else{
            self.hotelName = userInfo[@"aps"][@"alert"][@"title"];
        }
        self.currentSmoochToken = userInfo[@"data"][@"property_smooch_app_id"];
        self.smoochUserJwt = userInfo[@"data"][@"smooch_user_jwt"];
        SKTSettings *settings = [SKTSettings settingsWithAppId:userInfo[@"data"][@"property_smooch_app_id"]];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings completionHandler:nil];
        [[Smooch conversation] setDelegate:self];
        [Smooch login:self.smoochUserId jwt:self.smoochUserJwt completionHandler:nil];
        [Smooch show];
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:userInfo[@"data"]];
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else
    {
        if(self.isSmoochShow && [userInfo[@"data"][@"property_smooch_app_id"] isEqualToString:self.currentSmoochToken] ){
            
        }else{
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            if (notification)
            {
                notification.fireDate = [[NSDate date] dateByAddingTimeInterval:2];
                notification.alertBody = userInfo[@"aps"][@"alert"][@"body"];
                notification.soundName = UILocalNotificationDefaultSoundName;
            }
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
        completionHandler( UIBackgroundFetchResultNewData );
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    if(notification.request.content.userInfo[@"SmoochNotification"]){
        completionHandler(UIUserNotificationTypeNone  | UIUserNotificationTypeBadge);
    }else{
        self.status = @"foreground";
        if(notification.request.content.userInfo[@"data"][@"command"]){
            [self.bridge.eventDispatcher sendAppEventWithName:notification.request.content.userInfo[@"data"][@"command"] body:nil];
        }else if(notification.request.content.userInfo[@"data"][@"status"] && notification.request.content.userInfo[@"data"][@"room_number"]){
            [self.bridge.eventDispatcher sendAppEventWithName:notification.request.content.userInfo[@"data"][@"status"] body:notification.request.content.userInfo[@"data"]];
        }else{
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        }
        
        if(self.isSmoochShow && [notification.request.content.userInfo[@"data"][@"property_smooch_app_id"] isEqualToString:self.currentSmoochToken]){
            completionHandler(UIUserNotificationTypeNone  | UIUserNotificationTypeBadge);
        }else{
            completionHandler(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    if(response.notification.request.content.userInfo[@"data"][@"property_smooch_app_id"]){
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        if([response.notification.request.content.userInfo[@"data"][@"property_smooch_app_id"] isEqualToString:[ReactNativeConfig envFor:@"OKKAMI_SMOOCH"]]){
            NSMutableDictionary *newNotif = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *insideNewNotif = [[NSMutableDictionary alloc] init];
            [insideNewNotif setObject:[ReactNativeConfig envFor:@"OKKAMI_SMOOCH"] forKey:@"property_smooch_app_id"];
            [newNotif setObject:insideNewNotif forKey:@"data"];
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:newNotif[@"data"]];
        }else{
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:response.notification.request.content.userInfo[@"data"]];
        }

        [Smooch destroy];
        if([response.notification.request.content.userInfo[@"aps"][@"alert"][@"title"] isEqualToString:@""] || response.notification.request.content.userInfo[@"aps"][@"alert"][@"title"] == nil){
            self.hotelName = SMOOCH_NAME;
        }else{
            self.hotelName = response.notification.request.content.userInfo[@"aps"][@"alert"][@"title"];
        }
        self.currentSmoochToken = response.notification.request.content.userInfo[@"data"][@"property_smooch_app_id"];
        self.smoochUserJwt = response.notification.request.content.userInfo[@"data"][@"smooch_user_jwt"];
        SKTSettings *settings = [SKTSettings settingsWithAppId:response.notification.request.content.userInfo[@"data"][@"property_smooch_app_id"]];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings completionHandler:nil];
        [[Smooch conversation] setDelegate:self];
        [Smooch login:self.smoochUserId jwt:self.smoochUserJwt completionHandler:nil];
        [Smooch show];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
    }else if(response.notification.request.content.userInfo[@"data"][@"command"]){
        [self.bridge.eventDispatcher sendAppEventWithName:response.notification.request.content.userInfo[@"data"][@"command"] body:nil];
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:response.notification.request.content.userInfo[@"data"]];
    }else if(response.notification.request.content.userInfo[@"data"][@"status"] && response.notification.request.content.userInfo[@"data"][@"room_number"]){
        [self.bridge.eventDispatcher sendAppEventWithName:response.notification.request.content.userInfo[@"data"][@"status"] body:response.notification.request.content.userInfo[@"data"]];
    }
    completionHandler();
}
#pragma mark LineSDKLoginDelegate

- (void)didLogin:(LineSDKLogin *)login
      credential:(LineSDKCredential *)credential
         profile:(LineSDKProfile *)profile
           error:(NSError *)error
{
    if (error) {
         self.loginRejecter([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    } else {
        self.accessToken = credential.accessToken.accessToken;
        self.userId = profile.userID;
        self.displayName = profile.displayName;
        self.statusMessage = profile.statusMessage;
        if (profile.pictureURL) {
            self.pictureURL = profile.pictureURL.absoluteString;
        }else{
            self.pictureURL = @"";
        }
        NSError *error;
        self.lineData = [NSDictionary dictionaryWithObjectsAndKeys:self.accessToken,@"accessToken",self.userId,@"user_id",self.displayName, @"display_name", self.pictureURL,@"picture", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.lineData
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString* line;
        line = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.loginResolver(line);
        [self.bridge.eventDispatcher sendAppEventWithName:@"executeFromLine" body:line];
        
    }
}


RCT_EXPORT_METHOD(checkNotif:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject) {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Notifications.plist"];
    NSString *userPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] initWithContentsOfFile: plistPath];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile: userPath];
    if(notification){
        if(notification[@"data"][@"property_smooch_app_id"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isCheckNotif = YES;
                [Smooch destroy];
                if([notification[@"aps"][@"alert"][@"title"] isEqualToString:@""] || notification[@"aps"][@"alert"][@"title"] == nil){
                    self.hotelName = SMOOCH_NAME;
                }else{
                    self.hotelName = notification[@"aps"][@"alert"][@"title"];
                }
                self.currentSmoochToken = notification[@"data"][@"property_smooch_app_id"];
                self.smoochUserJwt = notification[@"data"][@"smooch_user_jwt"];
                SKTSettings *settings = [SKTSettings settingsWithAppId:notification[@"data"][@"property_smooch_app_id"]];
                settings.enableAppDelegateSwizzling = NO;
                settings.enableUserNotificationCenterDelegateOverride = NO;
                [Smooch initWithSettings:settings completionHandler:nil];
                [[Smooch conversation] setDelegate:self];
                [Smooch login:[userInfo objectForKey:@"userId"] jwt:self.smoochUserJwt completionHandler:nil];
                [Smooch show];
                [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
                [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:notification[@"data"]];
            });
        } else if(notification[@"data"][@"command"]) {
            [self.bridge.eventDispatcher sendAppEventWithName:notification[@"data"][@"command"] body:nil];
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:notification[@"data"]];
        } else {
            [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:notification[@"data"]];
        }
        [self deletePList:@"Notifications"];
    }
}

#pragma mark: -PushNotifications

- (void)registerInstanceId:(NSString *)instanceId {
    if (self.main) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.main registerInstanceIdWithInstanceId: instanceId];
        });
    }
}

- (void)registerForPusher:(NSData *)deviceToken {
    if (self.main) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.main registerForPusherWithDeviceToken: deviceToken];
        });
    }
}


- (void)subscribeToInterest:(NSString *)interest {
    if (self.main) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.main subscribeToInterestWithInterest: interest];
        });
    }
}

- (void)unsubscribeToInterest:(NSString *)interest {
    if (self.main) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.main unsubscribeToInterestWithInterest: interest];
        });
    }
}

- (void)unsubscribeAll {
    if (self.main) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.main unsubscribeAll];
        });
    }
}

- (void)setSubscriptions:(NSArray *)subscriptions {
    if (self.main) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.main setSubscriptionsWithInterests: subscriptions];
        });
    }
}

- (NSArray *)getInterests:(NSArray *)interests {
    return [self.main getInterests];
}

// TODO : THIS ONE IS HACKY WAY SHOULD BE USE LINKINGMANAGER in http://ihor.burlachenko.com/deep-linking-with-react-native/ --> do this after react upgrade
RCT_EXPORT_METHOD(checkEvent
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *deepLinkPath = [documentsDirectory stringByAppendingPathComponent:@"DeepLink.plist"];
    NSMutableDictionary *deeplink = [[NSMutableDictionary alloc] initWithContentsOfFile: deepLinkPath];
    
    if(deeplink){
        if(deeplink[@"data"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_SCREEN" body:@{@"screen" : deeplink[@"data"]}];
                [self deletePList:@"DeepLink"];
            });
        }else{
            [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_SCREEN" body:@{@"screen" : @"noscreen"}];
        }
    }else{
        [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_SCREEN" body:@{@"screen" : @"noscreen"}];
    }
}


RCT_EXPORT_METHOD(lineLogin:(RCTPromiseResolveBlock)resolve :(RCTPromiseRejectBlock)reject) {
    [LineSDKLogin sharedInstance].delegate = self;
    [[LineSDKLogin sharedInstance] startLogin];
    self.loginResolver = resolve;
    self.loginRejecter = reject;
    
}

- (CLLocationDegrees)deviceLat
{
    return self.locationManager.location.coordinate.latitude;
}


- (CLLocationDegrees)deviceLong
{
    return self.locationManager.location.coordinate.longitude;
}

RCT_EXPORT_METHOD(executeCoreRESTCall
                  
                  :(NSString*)endPoint
                  :(NSString*)getPost
                  :(NSString*)payLoad
                  :(NSString*)secret
                  :(NSString*)token
                  :(BOOL) force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    self.secretKey = secret;
    NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
    [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:@"Listener" object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [main executeCoreRESTCallWithNotif:defaultNotif apicore:endPoint apifunc:getPost payload:payLoad secret:secret token:token force:force completion:^(NSString* callback, NSError* error) {
            if (error == NULL) {
                resolve(callback);
                [self.bridge.eventDispatcher sendAppEventWithName:@"executeCoreRESTCall" body:callback];
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
            
        }];
    });
}

-(void)sendAnEvent:(NSString*)eventName :(NSDictionary*)userInfo{
    NSString *event = eventName;
    NSString *appToken = userInfo[@"data"][@"property_smooch_app_id"];
    [self.bridge.eventDispatcher sendAppEventWithName:event body:@{@"apptoken": appToken}];
    
}
- (void)listenerOkkami:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSString *event = [theData objectForKey:@"event"];
        NSString *command = [theData objectForKey:@"command"];
        if (command != nil) {
            [self.bridge.eventDispatcher sendAppEventWithName:event body:@{@"command": command}];
        }else{
            [self.bridge.eventDispatcher sendAppEventWithName:event body:nil];
        }
        if([event isEqualToString:@"identify"]){
            NSString *str = [theData objectForKey:@"data"];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSString *hmacStr = [self HMACSHA1:data secret:self.secretKey];
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@", hmacStr],@"HMAC",[NSString stringWithFormat:@"%@", str],@"data",
                                  nil];
            self.notifSocket =   [theData objectForKey:@"notif"];
            [self.notifSocket postNotificationName:@"ListenerSocket" object:NULL userInfo:dict];
        }else if([event isEqualToString:@"restcall"]){
            NSString *str = [theData objectForKey:@"data"];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSString *hmacStr = [self HMACSHA1:data secret:self.secretKey];
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@", hmacStr],@"HMAC",[NSString stringWithFormat:@"%@", str],@"data",
                                  nil];
            self.notifSocket =   [theData objectForKey:@"notif"];
            [self.notifSocket postNotificationName:@"ListenerSocketCore" object:NULL userInfo:dict];
        }
    }
}

RCT_EXPORT_METHOD(connectToHub
                  :(NSString*)uid
                  :(NSString*)secret
                  :(NSString*)token
                  :(NSString*)hubUrl
                  :(NSString*)hubPort
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    self.main = main;
    self.secretKey = secret;
    NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];

    [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.main.notificationName object:nil];
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    UInt16 portNumber = [[formatter numberFromString:hubPort] unsignedShortValue];
    [self.main connectToHubWithNotif:defaultNotif uid:uid secret:secret token:token hubUrl:hubUrl hubPort:portNumber completion:^(NSError * error) {
        if(error == nil){
            resolve(@YES);
        }else{
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Not connected To Room" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"E_ROOM_NOT_CONNECTED" code:401 userInfo:details];
            reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        }
    }];
}

RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:401 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.main disconnectFromHubWithCompletion:^(NSError * error) {
            if (error == nil) {
                [self.bridge.eventDispatcher sendAppEventWithName:@"disconnectFromHub" body:nil];
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }
}

RCT_EXPORT_METHOD(reconnectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:401 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
        [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.main.notificationName object:nil];    
        [self.main reconnectToHubWithNotif: defaultNotif completion:^(NSError * error) {
            if (error == nil) {
                [self.bridge.eventDispatcher sendAppEventWithName:@"reconnectToHub" body:nil];
                //ok
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }
    
}

RCT_EXPORT_METHOD(sendCommandToHub
                  
                  :(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:401 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [self.main sendCommandToHubWithCommand:command completion:^(NSError * error) {
            if (error == nil) {
                //[self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand" body:@{@"command": command}];
                //ok
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }

    
}

RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"OkkamiNotConnectedToHub" code:401 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [self.main isHubLoggedInCompletion:^(NSNumber * number) {
            [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:nil];
            //ok
            BOOL boolValue = [number boolValue];
            if (boolValue) {
                resolve(@YES);
            }else{
                resolve(@NO);
            }
        }];
    }
}

RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"OkkamiNotConnectedToHub" code:401 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [self.main isHubConnectedWithCompletion:^(NSNumber * number) {
            [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
            //ok
            BOOL boolValue = [number boolValue];
            
            if (boolValue) {
                resolve(@YES);
            }else{
                resolve(@NO);
            }
        }];
    }
    
}

RCT_EXPORT_METHOD(convertTime
                  
                  :(double) time
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *jsonObj = [main convertTimeWithNumber:time];
        resolve(jsonObj);
    });
}

RCT_EXPORT_METHOD(openChatWindow
                  
                  :(NSString *) smoochAppToken
                  :(NSString *) userID
                  :(NSString *) hotelName
                  :(NSString*) color
                  :(NSString*) textColor
                  :(BOOL) rgbColor
                  :(BOOL) rgbTextColor
                  :(NSString*) smoochUserJwt
                                    
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    self.hotelName = hotelName;
    self.currentSmoochToken = smoochAppToken;
    self.smoochUserJwt = smoochUserJwt;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Smooch destroy];
        SKTSettings *settings = [SKTSettings settingsWithAppId:smoochAppToken];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings completionHandler:nil];
        [[Smooch conversation] setDelegate:self];
        [Smooch login:self.smoochUserId jwt:self.smoochUserJwt completionHandler:nil];
        [Smooch show];
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
    });
}

RCT_EXPORT_METHOD(setAppBadgeIcon :(NSInteger)badgeIcon
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeIcon;
    });
}

RCT_EXPORT_METHOD(logoutChatWindow
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [Smooch close];
    [Smooch logoutWithCompletionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        [Smooch destroy];
    }];
    @try{
    [[self.appdel.pusher nativePusher] unsubscribe:self.appdel.channel_name];
         if (self.appdel.brand_name) {
             [[self.appdel.pusher nativePusher] unsubscribe:self.appdel.brand_name];
             
         }
    }
    @catch( NSException *exception){
        NSLog(@"[logoutChatWindow] Failed with error :  %@", exception.reason);
    }
    [self deletePList:@"UserInfo"];
    [self deletePList:@"Notifications"];

    /*if (!self.appdel.isOkkami) {
        [self unsubscribeAll];
    }*/
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

RCT_EXPORT_METHOD(setUserId
                  
                  :(NSString *) userId
                  :(NSString *) brandId
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appdel = appDelegate;
    
    if (self.appdel.channel_name) {
        [[self.appdel.pusher nativePusher] unsubscribe:self.appdel.channel_name];
        if (self.appdel.brand_name) {
            [[self.appdel.pusher nativePusher] unsubscribe:self.appdel.brand_name];
        }
    }
    
    NSString *channelName = [NSString stringWithFormat:@"mobile_user_%@", userId];
    NSString *brandName = [NSString stringWithFormat:@"mobile_user_%@_%@", userId, brandId];
    self.smoochUserId = userId;
    [self.appdel setUser_id:userId];
    [self.appdel setChannel_name:channelName];
    [self.appdel setBrand_name:brandName];
    
    [[self.appdel.pusher nativePusher] subscribe:channelName];
    [[self.appdel.pusher nativePusher] subscribe:brandName];

    /*if (!self.appdel.isOkkami) {
        [self subscribeToInterest:channelName];
        [self subscribeToInterest:brandName];
    }*/
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath: plistPath])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UserInfo" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundle toPath:plistPath error:&error];
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId",
                          nil];
    [dict writeToFile:plistPath atomically: YES];
    
    [self.appdel.pusher connect];
}


RCT_EXPORT_METHOD(setLanguage
                  
                  :(NSString *) language
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:language] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Language setLanguage: language];
    });
}

RCT_EXPORT_METHOD(subscribePushser
                  :(NSString *) deviceUid
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    //NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; //<---------whhhyyy are we getting uuid here?? its passed from app already!
    NSString *lastIdentifier = [deviceUid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    
    if (self.appdel) {
         [[self.appdel.pusher nativePusher] subscribe:[NSString stringWithFormat:@"mobile_device_%@", lastIdentifier]];
    }
}



@end
