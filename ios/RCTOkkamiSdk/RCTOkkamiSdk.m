#import "RCTOkkamiSdk.h"
#import "RCTEventDispatcher.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
#import <CoreLocation/CoreLocation.h>
//#import <RCTOkkamiSdkImplementation/RCTOkkamiSdkImplementation-Swift.h>

@implementation OkkamiSdk

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

-(id)init {
    if ( self = [super init] ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestWhenInUseAuthorization];
        //[self.locationManager requestAlwaysAuthorization];
        
        /*if ([CLLocationManager locationServicesEnabled]){
            CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
            
            [reverseGeocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (error){
                     return;
                 }
                 CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
                 
                 NSString *countryCode = myPlacemark.ISOcountryCode;
                 
                 NSString *latitude = [NSString stringWithFormat:@"%f",myPlacemark.location.coordinate.latitude];
                 NSString *longitude = [NSString stringWithFormat:@"%f",myPlacemark.location.coordinate.longitude];
                 
                 //[locationManager stopUpdatingLocation];
             }];
        }*/
    }
    return self;
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
    //NSLog(@"tess");
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [main executeCoreRESTCallWithApicore:endPoint apifunc:getPost payload:payLoad secret:secret token:token force:force completion:^(NSString* callback, NSError* error) {
            
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
    
    /*if ([endPoint containsString:@"location_services"]) {
        
        if (![CLLocationManager locationServicesEnabled]) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Please Turn On Your Location Services" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"OkkamiLocationOFF" code:201 userInfo:details];
            reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        }
        RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
        NSString *newEndPoint =[NSString stringWithFormat:@"%@lat=%.7f&lng=%.7f",endPoint,self.deviceLat,self.deviceLong];
        
        //use below only for testing using simulator
        //NSString *newEndPoint =[NSString stringWithFormat:@"%@lat=13.7441961&lng=100.5568176", endPoint];
        NSLog(@"%@",newEndPoint);
        
        
        
        [main executeCoreRESTCallWithApicore:newEndPoint apifunc:getPost payload:payLoad secret:secret token:token force:force completion:^(NSString* callback, NSError* error) {
            
            NSLog(@"callback %@", callback);
            NSLog(@"error %@", error);
            
            if (error == NULL) {
                resolve(callback);
                [self.bridge.eventDispatcher sendAppEventWithName:@"executeCoreRESTCall" body:callback];
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
            
        }];
        
    } else {
        RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
        [main executeCoreRESTCallWithApicore:endPoint apifunc:getPost payload:payLoad secret:secret token:token force:force completion:^(NSString* callback, NSError* error) {
            
            NSLog(@"callback %@", callback);
            NSLog(@"error %@", error);
            
            if (error == NULL) {
                resolve(callback);
                [self.bridge.eventDispatcher sendAppEventWithName:@"executeCoreRESTCall" body:callback];
            }else{
                reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            }
            
        }];
    }*/
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
        
    }];
    /*[self.main connectToHubWithUid:uid secret:secret token:token hubUrl:hubUrl hubPort:portNumber completion:^(NSError * error) {
        
        if (error == nil) {
            resolve(@YES);
        }else{
            reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
            
            /*[main disconnectFromHubWithCompletion:^(NSError * errorDisc) {
                if (errorDisc == nil) {
                    reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
                }
            }];
        }*/
        /*if (error == nil) {
            [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
            [main identifyDeviceIdWithCompletion:^(NSError * error) {
                if (error==nil) {
                    
                    
                    //[self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:nil];
                    //ok
                    //resolve(@YES);
                }else{
                    reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
                }
            }];
        }else{
            reject([NSString stringWithFormat:@"%ld", error.code],error.description, error);
        }
    }];*/
    
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


RCT_EXPORT_METHOD(smoochChat
                  
                  :(NSString*)appToken
                  :(NSString*)userID
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    /*if (self.smooch == nil) {
        OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:appToken];
        self.smooch = smooch;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.smooch smoochChat];
        });
    }else{
        if ([self.smooch.appToken isEqualToString:appToken]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smooch smoochChat];
            });
        }else{
            OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstanceWithAppToken:appToken];
            dispatch_async(dispatch_get_main_queue(), ^{
                [smooch smoochChat];
            });
        }
    }*/
    if (self.smooch == nil) {
        OkkamiSmoochChat *smooch = [OkkamiSmoochChat newInstance];
        self.smooch = smooch;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.smooch smoochChatWithAppToken:appToken user:userID];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.smooch smoochChatWithAppToken:appToken user:userID];
        });
    }
    
}

RCT_EXPORT_METHOD(smoochLogout
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.smooch smoochChat];
    });
}








/*-------------------------------------- Utility   --------------------------------------------------*/


/**
 * Delete stored information of the user
 */

/*RCT_EXPORT_METHOD(wipeUserData
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}*/

/**
 * Entry point of the native sdk
 */


RCT_EXPORT_METHOD(start
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    NSString* udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* payload = [NSString stringWithFormat:@"{\"uid\":\"%@\"}", udid];
    
    /*[main executeCoreRESTCallWithApicore:@"https://api.fingi-staging.com/v1/preconnect" apifunc:@"POST" payload:payload secret:@"92865cbcd9be8a19d0563006f8b81c73" token:@"32361e1a5a496e0c" force:1 completion:^(id callback) {
        resolve(callback);
        [self.bridge.eventDispatcher sendAppEventWithName:@"onStart" body:@{@"command": @"On Start"}];
    }];*/
    /*RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    NSString* udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* payload = [NSString stringWithFormat:@"{\"uid\":\"%@\"}", udid];
    [main executeCoreRESTCallWithApicore:@"https://api.fingi-staging.com/v1/preconnect" apifunc:@"POST" payload:payload secret:@"" token:@"" completion:^(id callback) {
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callback options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resolve(callback);
        [self.bridge.eventDispatcher sendAppEventWithName:@"onStart" body:@{@"command": @"On Start"}];
        
    }];*/
    //[main executeCoreRESTCallWithApicore:@"https://api.fingi-staging.com/v1/preconnect" apifunc:@"POST" payload:payload];
    
}

/**
 * restart the native sdk,
 * basically stop and call the entry point of the sdk
 */

/*
RCT_EXPORT_METHOD(restart
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    
}*/

/*---------------------------------------------------------------------------------------------------*/


/*-------------------------------------- Hub & Core -------------------------------------------------*/

/**
 * Connect to room. Applicable to downloadable apps
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 * The native module should take care of persisting the device secret and token obtained from core
 * and making sure it is secure/encrypted
 */
/*
RCT_EXPORT_METHOD(connectToRoom
                  :(NSString*)username
                  :(NSString*)password
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main connectToRoomWithRoom:@"demo3" token:@"1234"];
    [self.bridge.eventDispatcher sendAppEventWithName:@"connectToRoom" body:@{@"command": @"Connect To Room"}];

    
}
*/

/**
 * Disconnects from the current room. Applicable to downloadable apps.
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 */
/*
RCT_EXPORT_METHOD(disconnectFromRoom
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main disconnectFromRoom];
    [self.bridge.eventDispatcher sendAppEventWithName:@"disconnectFromRoom" body:@{@"command": @"Disconnect From Room"}];
}*/

/**
 * Registers the device with a room using the given UID .
 * Applicable to property locked Apps
 * on success: resolve(NSString* coreResponseJSONString )
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 * The native module should take care of persisting the device secret and token obtained from core
 * and making sure it is secure/encrypted
 */
/*
RCT_EXPORT_METHOD(registerToCore
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}*/

/**
 * Connects to hub using the presets and attempts to login ( send IDENTIFY)
 * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
 * on success: resolve(true)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 * Native module should also take care of the PING PONG and reconnect if PING drops
 */
/*
RCT_EXPORT_METHOD(connectToHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
 
    
    RCTOkkamiMain *helloWorld = [RCTOkkamiMain newInstance];
    [helloWorld getGuestService];
    //[helloWorld preConnect];
    //[helloWorld connectToRoom];
    //[helloWorld postToken];
    
    //RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:self.bridge moduleName:@"ImageBrowserApp" initialProperties:[helloWorld setupRx]];
    //NSString *test = [helloWorld setupRx];
//    if (test) {
//        resolve(test);
//    } else {
//        //reject(test);
//    }
    
}
*/

/**
 * Disconnects and cleans up the existing connection
 * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
 * on success: resolve(true)
 * on failure: reject(@"xxx", @"xxx", NSError * error)
 *
 */
/*
RCT_EXPORT_METHOD(disconnectFromHub
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubDisconnected" body:nil];
}

*/

/**
 * Send command to hub. a command can look like this:
 * POWER light-1 ON
 * 2311 Default | POWER light-1 ON
 * 1234 2311 Default | POWER light-1 ON
 * <p>
 * The native module should fill in the missing info based on the command received
 * such as filling in room , group , none if not provided and skip those if provied already
 * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
 * on failure:  hubDisconnectionPromise.reject(@"xxx", @"xxx", NSError * error)
 */
/*
RCT_EXPORT_METHOD(sendCommandToHub:(NSString*)command
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand"
                                                 body:@{@"command": @"1234 2311 Default | POWER light-1 ON"}];
    
}
*/

/**
 * downloads presets from core.
 * If force == YES, force download from core
 * If force == NO, and there is already presets from core, reply with that
 * on success : resolve(coreResponseJSONString)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 */
/*
RCT_EXPORT_METHOD(downloadPresets
                  :(BOOL)force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main downloadPresetsWithForce:1];
    [self.bridge.eventDispatcher sendAppEventWithName:@"downloadPresets"
                                                 body:@{@"command": @"Download Presets"}];
}
*/
/**
 * Similar strategy as downloadPresets method
 *
 */
/*
RCT_EXPORT_METHOD(downloadRoomInfo
                  :(BOOL)force
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    RCTOkkamiMain *main = [RCTOkkamiMain newInstance];
    [main downloadRoomInfoWithForce:1];
    [self.bridge.eventDispatcher sendAppEventWithName:@"downloadRoomInfo"
                                                 body:@{@"command": @"Download Room Info"}];
}
*/
/**
 * The purpose of this method is to provide general purpose way to call any core endpoint.
 * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
 * <p>
 * on success : resolve(coreResponseJSONString)
 * on failure:  reject(@"xxx", @"xxx", NSError * error)
 *
 * @param endPoint                full core url . https://api.fingi.com/devices/v1/register
 * @param getPost                 "GET" or "POST"
 * @param payload                 JSON encoded payload if it is POST
 */
/*
RCT_EXPORT_METHOD(downloadFromCore
                  
                  :(NSString*)endPoint
                  :(NSString*)getPost
                  :(NSString*)payLoad
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}

*/
/**
 * if hub is currently connected + logged in :
 * resolve(true);
 * else
 * resolve(false);
 */
/*
RCT_EXPORT_METHOD(isHubLoggedIn
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:@{@"command": @"Hub Logged In"}];
    //ok
    resolve(@YES);
    
}*/

/**
 * if hub is currently connected ( regardless of logged in )  :
 * resolve(true);
 * else
 * resolve(false);
*
 */
/*
RCT_EXPORT_METHOD(isHubConnected
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
    //ok
    resolve(@YES);
    
}
*/


//Events emission
/*
 *  onHubCommand
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubCommand"
 *       body:@{@"command": @"1234 2311 Default | POWER light-1 ON"}];
 *
 *
 *  onHubConnected
 *   
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubConnected" body:nil];
 *
 *
 *  onHubLoggedIn ( when IDENTIFIED is received )
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubLoggedIn" body:nil];
 *
 *
 *  onHubDisconnected
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onHubDisconnected" body:nil];
 *
 *
 * */



/*---------------------------------------------------------------------------------------------------*/

/*-------------------------------------- SIP / PhoneCall --------------------------------------------*/


// SIP should be enabled / disabled autometically by the native sdk based on what is set in the preset
// If Downloadable app, registration should not persist when app is in background
// If property locked app, registration should persist even in background . Not applicable to iOS apps .
// Registration should happen as soon as downloadPresets is successful


/**
 * Dial a number. if voip Not available, dial using native dialer
 *
 * @param calledNumber
 * @param preferSip
 */
/*
RCT_EXPORT_METHOD(dial
                  
                  :(NSString*)calledNumber
                  :(BOOL)preferSip
            
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    
}
*/

/**
 * Attempt to accept an incoming voip call
 */

/*
RCT_EXPORT_METHOD(receive
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{

    
}
 */
/**
 * Hangup an incoming / ongoing voip Call
 *
 * @param hangupPromise
 */
/*
RCT_EXPORT_METHOD(hangup
                  
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject)
{
    //ok
    resolve(@YES);
    
}
*/





//Events emission
/*
 *  onIncomingCall
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onIncomingCall"
 *       body:@{@"caller": @"CALLER_NUMBER",  @"uniqueId":  @"CALL_UNIQUE_ID", @"eventData":  @"JSON_STRING"}];
 *
 *  onSipEvent
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onSipEvent"
 *       body:@{@"eventNumber": @"SIP_EVENT_NUMBER_LIKE_200_400_404_ETC", @"JSON_STRING"}];
 *
 *  onCallHangup
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onCallHangup"
 *       body:@{@"caller": @"CALLER_NUMBER",  @"uniqueId":  @"CALL_UNIQUE_ID", @"eventData":  @"JSON_STRING"}];
 *
 *  onSipRegistrationStatusChanged
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onSipRegistrationStatusChanged"
 *       body:@{@"status": @"STATUS", @"eventData":  @"JSON_STRING"}]; // status should be one of : REGISTERING, REGISTERED , AUTHENTICATION_FAILURE , UNREGISTERED ,
 */




/*---------------------------------------------------------------------------------------------------*/



/*-------------------------------------- WIFI --------------------------------------------------------*/

//wifi status is to be managed by the native sdk internally.
//for property locked app, the sdk should set SSID and password as soon as downloadPresets is successful


//Events emission
/*
 *
 *  onWifiStatusChanged
 *
 *   [self.bridge.eventDispatcher sendAppEventWithName:@"onWifiStatusChanged"
 *       body:@{@"status": @"STATUS", @"eventData":  @"JSON_STRING"}]; // status should be one of : CONNECTING,CONNECTED,DISCONNECTED
 **/


/*---------------------------------------------------------------------------------------------------*/


/*-------------------------------------- Keys --------------------------------------------------------*/

//?? need discussion


/*---------------------------------------------------------------------------------------------------*/




@end
