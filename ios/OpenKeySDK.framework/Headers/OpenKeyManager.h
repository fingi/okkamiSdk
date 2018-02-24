//
//  OpenKeyManager.h
//  OpenKeySampleProject
//
//  Created by TpSingh on 07/03/17.
//  Copyright © 2017 openkey. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol OpenKeyManagerDelegate <NSObject>
    @optional
    
- (void) authenticateResponse : (NSString*) response status:(BOOL) status;
- (void) initializeSDKResponse : (NSString*) response status: (BOOL) endpointStatus;
- (void) fetchMobileKeysResponse: (NSString*) response status:(BOOL) keysStatus;
    //- (void) isKeyAvailableResponse: (BOOL) keysStatus;
- (void) startScanningResponse: (NSString*) response status: (BOOL) scanStatus;
- (void) stopScanningResponse:(NSString*) response status:(BOOL) scanStatus;
    
    
    @end


@interface OpenKeyManager : NSObject{
    NSString * manufacturerType;
}
    
    @property (nonatomic, strong) id <OpenKeyManagerDelegate> delegate;
    @property (nonatomic, strong) NSString * manufacturerType;
    
+ (OpenKeyManager *) shared;
    
    //Exposed Methods
    
    //Authenticate with Openkey Server, pass a unique secret key to this method, it will return response in ((void) authWithSecretKey : (NSString*) response status:(BOOL) status)
- (void) authenticate : (NSString *) secretKey withDelegate:(id) inputDelegate;
    
    
    //A unique numeric identifier is needed, most preferable would be mobile number. An endpoint will be created with unique number passed, further this endpoint will be used for receiving keys etc
- (void) initializeSDK:(id) inputDelegate;
    
    
    //Mehod fetch keys from server and securely save in OpenKey SDK, response retruned in (- (void) fetchMobileKeysResponse: (NSString*) response status:(BOOL) keysStatus;)
- (void) fetchMobileKeys :(id) inputDelegate;
    
    
    //This method is used to check fast if device have any key in SDK, it will retrun TRUE / FALSE, depends on device have key or not in OpeKeySDK.
    //- (void) isKeyAvailable;
    
    
    //Start scaning is called if you want to open lock, it will start BLE Reader to communicate with locks. Reposne of lock returned in delegate - (- (void) startScanningResponse: (NSString*) response status: (BOOL) scanStatus;)
- (void) startScanning :(id) inputDelegate;;
    
    
    //Method is called to stop BLE Reader for scanning.
- (void) stopScanning;
    
    @end

