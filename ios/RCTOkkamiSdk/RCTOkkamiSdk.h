#import "RCTBridge.h"
#import <LineSDK/LineSDK.h>
#import "RCTBridgeModule.h"
#import <CoreLocation/CoreLocation.h>

@import RCTokkamiiossdk;

@interface OkkamiSdk : NSObject <RCTBridgeModule, LineSDKLoginDelegate, CLLocationManagerDelegate>
@property (nonatomic, copy)NSString * accessToken;
@property (nonatomic, copy)NSString * userId;
@property (nonatomic, copy)NSString * displayName;
@property (nonatomic, copy)NSString * statusMessage;
@property (nonatomic, copy)NSString * pictureURL;
@property (copy, nonatomic) NSDictionary * lineData;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (strong, nonatomic) RCTPromiseResolveBlock loginResolver;
@property (strong, nonatomic) RCTPromiseRejectBlock loginRejecter;
@property (strong, nonatomic) RCTOkkamiMain* main;
@property (strong, nonatomic) OkkamiSmoochChat* smooch;
@property (strong, nonatomic) RCTEventDispatcher* event;
@end
