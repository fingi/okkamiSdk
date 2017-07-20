#import "RCTOkkamiSdk.h"
#import "AppDelegate.h"


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
        NetworkClock * nc = [NetworkClock sharedNetworkClock];
        self.currentDate = nc;
        self.netAssociation = [[NetAssociation alloc] initWithServerName:[NetAssociation ipAddrFromName:@"time.apple.com"]];
        self.netAssociation.delegate = self;
        [self.netAssociation sendTimeQuery];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
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
        //TODO: Handle/Log error
    }
}


- (void)openSmooch: (NSString*)appToken userId:(NSString*)userId title:(NSString*)title {
    //enhancement put open smooch all in here
    [Smooch destroy];
    if([title isEqualToString:@""] || title == nil){
        self.hotelName = SMOOCH_NAME;
    }else{
        self.hotelName = title;
    }
    self.currentSmoochToken = appToken;
    SKTSettings *settings = [SKTSettings settingsWithAppToken:appToken];
    settings.enableAppDelegateSwizzling = NO;
    settings.enableUserNotificationCenterDelegateOverride = NO;
    [Smooch initWithSettings:settings];
    [[Smooch conversation] setDelegate:self];
    [Smooch login:self.smoochUserId jwt:nil];
    [Smooch show];
    
}


- (void)handleOkkamiUrl: (NSString*)url title: (NSString*)title {
    NSString *preTel;
    NSString *postTel;
    
    NSScanner *scanner = [NSScanner scannerWithString:url];
    [scanner scanUpToString:OKKAMI_DEEPLINK intoString:&preTel];
    [scanner scanString:OKKAMI_DEEPLINK intoString:nil];
    postTel = [url substringFromIndex:scanner.scanLocation];
    [self.bridge.eventDispatcher sendAppEventWithName:@"OPEN_WEBVIEW" body:@{@"hotelName":self.hotelName,@"title":title,@"url":postTel,@"appToken": self.currentSmoochToken}];
    [self.currentViewController dismissViewControllerAnimated:true completion:nil];
    
}

- (void)sendEvent: (NSString*)eventName :(NSDictionary*)eventBody {
    [self.bridge.eventDispatcher sendAppEventWithName:eventName body:eventBody];
}

- (void) reportFromDelegate {
    NSLog(@"REPORT : %@", [NSString stringWithFormat:@"System ahead by: %5.3f mSec",
                           self.netAssociation.offset * 1000.0]);
    
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
}

- (BOOL)conversation:(SKTConversation *)conversation shouldHandleMessageAction:(SKTMessageAction *)action{
    if(action.uri != nil && [action.uri.absoluteString containsString:OKKAMI_DEEPLINK]){
        [self handleOkkamiUrl:action.uri.absoluteString title:action.text];
        return NO;
    }
    return YES;
}

#pragma mark Pusher Delegate
-(void) pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel{
    NSLog(@"didSubscribeToChannel : %@", channel);
}
-(void) pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel{
    NSLog(@"didUnsubscribeFromChannel : %@", channel);
}
-(void) nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId{
    NSLog(@"didRegisterForPushNotificationsWithClientId : %@", clientId);
}
-(void) nativePusher:(PTNativePusher *)nativePusher didSubscribeToInterest:(NSString *)interestName{
    NSLog(@"didSubscribeToInterest : %@", interestName);
}
-(void) nativePusher:(PTNativePusher *)nativePusher didUnsubscribeFromInterest:(NSString *)interestName{
    NSLog(@"didUnsubscribeFromInterest : %@", interestName);
}


#pragma mark Notif Delegate

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"ERROR REGISTER: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"DID REGISTER REMOTE ??? from RCTOkkamiSdk:");
    [Smooch logout];
    [Smooch destroy];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appdel = appDelegate;
    [[self.appdel.pusher nativePusher] registerWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [Smooch logout];
    [Smooch destroy];
    NSLog(@"DID RECEIVE REMOTE ? from RCTOkkamiSdk:");
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void
                                                                                                                               (^)(UIBackgroundFetchResult))completionHandler
{
    // iOS 10 will handle notifications through other methods
    
    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification from RCTOkkamiSdk: %@", userInfo );
    [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:userInfo[@"data"]];
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
        return;
    }
    
    // custom code to handle notification content
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:userInfo[@"data"]];
        if([userInfo[@"aps"][@"alert"][@"title"] isEqualToString:@""] || userInfo[@"aps"][@"alert"][@"title"] == nil){
            self.hotelName = SMOOCH_NAME;
        }else{
            self.hotelName = userInfo[@"aps"][@"alert"][@"title"];
        }
        self.currentSmoochToken = userInfo[@"data"][@"property_smooch_app_token"];
        SKTSettings *settings = [SKTSettings settingsWithAppToken:userInfo[@"data"][@"property_smooch_app_token"]];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings];
        [[Smooch conversation] setDelegate:self];
        [Smooch login:self.smoochUserId jwt:nil];
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
        if(self.isSmoochShow && [userInfo[@"data"][@"property_smooch_app_token"] isEqualToString:self.currentSmoochToken] ){
            
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
    NSLog( @"Handle push from foreground" );
    NSLog(@"%@", notification.request.content.userInfo);
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
        
        if(self.isSmoochShow && [notification.request.content.userInfo[@"data"][@"property_smooch_app_token"] isEqualToString:self.currentSmoochToken]){
            completionHandler(UIUserNotificationTypeNone  | UIUserNotificationTypeBadge);
        }else{
            completionHandler(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSLog( @"Handle push from background or closed" );
    if(response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"]){
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        if([response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"] isEqualToString:[ReactNativeConfig envFor:@"OKKAMI_SMOOCH"]]){
            NSMutableDictionary *newNotif = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *insideNewNotif = [[NSMutableDictionary alloc] init];
            [insideNewNotif setObject:[ReactNativeConfig envFor:@"OKKAMI_SMOOCH"] forKey:@"property_smooch_app_token"];
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
        self.currentSmoochToken = response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"];
        SKTSettings *settings = [SKTSettings settingsWithAppToken:response.notification.request.content.userInfo[@"data"][@"property_smooch_app_token"]];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings];
        [[Smooch conversation] setDelegate:self];
        [Smooch login:self.smoochUserId jwt:nil];
        [Smooch show];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
    }else if(response.notification.request.content.userInfo[@"data"][@"command"]){
        [self.bridge.eventDispatcher sendAppEventWithName:response.notification.request.content.userInfo[@"data"][@"command"] body:nil];
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
    NSLog(@"come here ? %@", error);
    if (error) {
        NSLog(@"Error data : %@", error);
        self.loginRejecter([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        // Login failed with an error. You can use the error parameter to help determine what the problem was.
    }
    else {
        
        // Login has succeeded. You can get the user's access token and profile information.
        self.accessToken = credential.accessToken.accessToken;
        self.userId = profile.userID;
        self.displayName = profile.displayName;
        self.statusMessage = profile.statusMessage;
        // If the user does not have a profile picture set, pictureURL will be nil
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


RCT_EXPORT_METHOD(checkNotif
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Notifications.plist"];
    NSString *userPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] initWithContentsOfFile: plistPath];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile: userPath];
    
    if(notification){
        if(notification[@"data"][@"property_smooch_app_token"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isCheckNotif = YES;
                [Smooch destroy];
                if([notification[@"aps"][@"alert"][@"title"] isEqualToString:@""] || notification[@"aps"][@"alert"][@"title"] == nil){
                    self.hotelName = SMOOCH_NAME;
                }else{
                    self.hotelName = notification[@"aps"][@"alert"][@"title"];
                }
                
                self.currentSmoochToken = notification[@"data"][@"property_smooch_app_token"];
                SKTSettings *settings = [SKTSettings settingsWithAppToken:notification[@"data"][@"property_smooch_app_token"]];
                settings.enableAppDelegateSwizzling = NO;
                settings.enableUserNotificationCenterDelegateOverride = NO;
                [Smooch initWithSettings:settings];
                [[Smooch conversation] setDelegate:self];
                [Smooch login:[userInfo objectForKey:@"userId"] jwt:nil];
                [Smooch show];
                [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber -1;
                [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NOTIF_CLICKED" body:notification[@"data"]];
                [self deletePList:@"Notifications"];
            });
        }
    }
}


RCT_EXPORT_METHOD(lineLogin
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [LineSDKLogin sharedInstance].delegate = self;
    NSLog(@"equal to line");
    [[LineSDKLogin sharedInstance] startLogin];
    self.loginResolver = resolve;
    self.loginRejecter = reject;
    
}

/**
 * The purpose of this method is to provide general purpose way to call any core endpoint.
 * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
 * <p>
 * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
 * on failure:  downloadFromCorePromise.reject(Throwable e)
 *
 * @param endPoint                full core url . https://api.fingi.com/devices/v1/register
 * @param getPost                 "GET" or "POST"
 * @param payload                 JSON encoded payload if it is POST
 * @param downloadFromCorePromise
 */


// Wait for location callbacks
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
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
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    NSDate * date = [[NSDate date] dateByAddingTimeInterval:-self.netAssociation.offset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [main executeCoreRESTCallWithApicore:endPoint apifunc:getPost payload:payLoad secret:secret token:token force:force date: date completion:^(NSString* callback, NSError* error) {
            
            NSLog(@"callback %@", callback);
            NSLog(@"error %@", error);
            
            if (error == NULL) {
                resolve(callback);
                [self.bridge.eventDispatcher sendAppEventWithName:@"executeCoreRESTCall" body:callback];
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
            
        }];
    });
}

/**
 * Connects to hub using the presets and attempts to login ( send IDENTIFY)
 * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
 * on success: hubConnectionPromise.resolve(true)
 * on failure:  hubConnectionPromise.reject(Throwable e)
 * Native module should also take care of the PING PONG and reconnect if PING drops
 *
 * @param secrect secrect obtained from core
 * @param token   token obtained from core
 * @param hubConnectionPromise
 */

-(void)sendAnEvent:(NSString*)eventName :(NSDictionary*)userInfo{
    NSString *event = eventName;
    NSString *appToken = userInfo[@"data"][@"property_smooch_app_token"];
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
    }
    
}

RCT_EXPORT_METHOD(connectToHub
                  :(NSString*)uid
                  :(NSString*)secret
                  :(NSString*)token
                  :(NSString*)hubUrl
                  :(NSString*)hubPort
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    self.main = main;
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
            NSError *error = [NSError errorWithDomain:@"E_ROOM_NOT_CONNECTED" code:1200 userInfo:details];
            reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        }
    }];
}


/**
 * Disconnects and cleans up the existing connection
 * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
 * on success: hubDisconnectionPromise.resolve(true)
 * on failure:  hubDisconnectionPromise.reject(Throwable e)
 *
 * @param hubDisconnectionPromise
 */
RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:200 userInfo:details];
        reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.main disconnectFromHubWithCompletion:^(NSError * error) {
            if (error == nil) {
                [self.bridge.eventDispatcher sendAppEventWithName:@"disconnectFromHub" body:nil];
                //ok
                resolve(@YES);
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
        }];
    }
}

/**
 * Disconnects and cleans up the existing connection
 * Then attempt to connect to hub again.
 * on success ( hub has been successfully reconnected and logged in ) : hubReconnectionPromise.resolve(true)
 * on failure:  hubReconnectionPromise.reject(Throwable e)
 *
 * @param hubReconnectionPromise
 */

RCT_EXPORT_METHOD(reconnectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:200 userInfo:details];
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

/**
 * Send command to hub. a command can look like this:
 * POWER light-1 ON
 * 2311 Default | POWER light-1 ON
 * 1234 2311 Default | POWER light-1 ON
 * <p>
 * The native module should fill in the missing info based on the command received
 * such as filling in room , group , none if not provided and skip those if provied already
 * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
 * on failure:  hubDisconnectionPromise.reject(Throwable e)
 *
 * @param sendMessageToHubPromise
 */

RCT_EXPORT_METHOD(sendCommandToHub
                  
                  :(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"E_HUB_NOT_CONNECTED" code:200 userInfo:details];
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



/**
 * if hub is currently connected + logged in :
 * hubLoggedPromise.resolve(true);
 * else
 * hubLoggedPromise.resolve(false);
 *
 * @param hubLoggedPromise
 */

RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"OkkamiNotConnectedToHub" code:200 userInfo:details];
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

/**
 * if hub is currently connected ( regardless of logged in ) :
 * hubConnectedPromise.resolve(true);
 * else
 * hubConnectedPromise.resolve(false);
 *
 * @param hubConnectedPromise
 */


RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    if (self.main == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Not connected To Hub" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"OkkamiNotConnectedToHub" code:200 userInfo:details];
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

/*-------------------------------------- Smooch   --------------------------------------------------*/




RCT_EXPORT_METHOD(convertTime
                  
                  :(double) time
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"HOHOHO");
        NSString *jsonObj = [main convertTimeWithNumber:time];
        resolve(jsonObj);
    });
}
RCT_EXPORT_METHOD(getConversationsList
                  
                  :(NSArray*) smoochAppToken
                  :(NSString*) userID
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    if(!self.smooch){
        OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:smoochAppToken[0]];
        self.smooch = smooch;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *jsonObj = [self.smooch getConversationsListWithArray:smoochAppToken userID: userID];
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
                                    
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    self.hotelName = hotelName;
    self.currentSmoochToken = smoochAppToken;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Smooch destroy];
        SKTSettings *settings = [SKTSettings settingsWithAppToken:smoochAppToken];
        settings.enableAppDelegateSwizzling = NO;
        settings.enableUserNotificationCenterDelegateOverride = NO;
        [Smooch initWithSettings:settings];
        [[Smooch conversation] setDelegate:self];
        [Smooch login:self.smoochUserId jwt:nil];
        [Smooch show];
        [self.bridge.eventDispatcher sendAppEventWithName:@"EVENT_NEW_MSG" body:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
    });
}


RCT_EXPORT_METHOD(getUnreadMessageCount
                  
                  :(NSString *) smoochAppToken
                  :(NSString *) userID
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    NSUInteger unreadMessage = [self.smooch getUnreadMessageCount];
    NSString *unread = [NSString stringWithFormat:@"%ld", unreadMessage];
    resolve(unread);
}


RCT_EXPORT_METHOD(setAppBadgeIcon :(NSInteger)badgeIcon
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeIcon;
}

RCT_EXPORT_METHOD(logoutChatWindow
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [self.smooch okkamiLogout];
    NSLog(@"UNSUBSCRIBE TO %@", self.appdel.channel_name);
    [[self.appdel.pusher nativePusher] unsubscribe:self.appdel.channel_name];
    [self deletePList:@"UserInfo"];
    [self deletePList:@"Notifications"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


RCT_EXPORT_METHOD(loginChatWindow
                  
                  :(NSString *) userID
                  :(NSString *) appToken
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:appToken];
    self.smooch = smooch;
    NSNotificationCenter *defaultNotif = [NSNotificationCenter defaultCenter];
    [defaultNotif addObserver:self selector:@selector(listenerOkkami:) name:self.smooch.notificationName object:nil];
    [self.smooch addNotifWithNotif: defaultNotif];
    [self.smooch smoochLoginWithUser:userID];
}

RCT_EXPORT_METHOD(setUserId
                  
                  :(NSString *) userId
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appdel = appDelegate;
    NSString *channelName = [NSString stringWithFormat:@"mobile_user_%@", userId];
    self.smoochUserId = userId;
    NSLog(@"===SET USER ID====%@", channelName);
    [self.appdel setUser_id:userId];
    [self.appdel setChannel_name:channelName];
    [[self.appdel.pusher nativePusher] subscribe:channelName];

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
    NSLog(@"===PLIST PATH====%@", plistPath);
    [dict writeToFile:plistPath atomically: YES];
    
    [self.appdel.pusher connect];
}


RCT_EXPORT_METHOD(setLanguage
                  
                  :(NSString *) language
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    NSLog(@"Language : %@", language);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:language] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Language setLanguage: language];
    });
}

@end
