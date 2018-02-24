// MobileKeysManagerDelegate.h
// Copyright (c) 2014 ASSA ABLOY Mobile Services ( http://assaabloy.com/seos )
//
// All rights reserved.

#import <Foundation/Foundation.h>
#import "MobileKeysReader.h"

@class MobileKeysReader;
@class MobileKeysOpeningResult;

/**
 * Delegate protocol to implement for callbacks from the `MobileKeysManager` class
 * @see `MobileKeysManager`
 */
@protocol MobileKeysManagerDelegate

 /**
 * Callback for when `-[MobileKeysManager startup]` was successfully completed.
 * @note since version 2.0
 */
- (void)mobileKeysDidStartup;

/**
 * Callback for when `-[MobileKeysManager startup]` failed.
 * @param error - The cause of the failure, code is one of `MobileKeysErrorCode`.
 * @note since version 2.0
 */
- (void)mobileKeysDidFailToStartup:(NSError *)error;

 /**
 * Callback for when `-[MobileKeysManager setupEndpoint]` was successfully completed. The endpoint is now setup.
 * @note since version 2.0
 */
- (void)mobileKeysDidSetupEndpoint;

 /**
 * Callback for when `-[MobileKeysManager setupEndpoint]` failed. The endpoint hasn't been setup.
 * @param error - The cause of the failure, code is one of `MobileKeysErrorCode`.
 * @note since version 2.0
 */
- (void)mobileKeysDidFailToSetupEndpoint:(NSError *)error;

 /**
 * Callback for when `-[MobileKeysManager updateEndpoint]` was successfully completed and the endpoint has been updated.
 * @note since version 2.0
 */
- (void)mobileKeysDidUpdateEndpoint;

 /**
 * Callback for when `-[MobileKeysManager updateEndpoint]` failed. The endpoint wasn't updated.
 * @param error - The cause of the failure, code is one of `MobileKeysErrorCode`.
 * @note since version 2.0
 */
- (void)mobileKeysDidFailToUpdateEndpoint:(NSError *)error;

 /**
 * Callback for when the endpoint has been terminated. This can happen even without calling `-[MobileKeysManager updateEndpoint]`.
 * @note since version 2.0
 */
- (void)mobileKeysDidTerminateEndpoint;

 /**
 * Callback for when the application has just connected to reader.
 * @param reader - The reader which the application has connected to.
 * @param type - The type of opening which connected the application with reader.
 * @note since version 4.0
 */
- (void)mobileKeysDidConnectToReader:(MobileKeysReader *)reader openingType:(MobileKeysOpeningType)type;

 /**
 * Callback for when a connection has failed.
 * @param reader - The reader which the application failed to connect to.
 * @param type - The type of opening which initiated the connection attempt.
 * @param status - Status of the failed connection
 * @note since version 2.0
 */
- (void)mobileKeysDidFailToConnectToReader:(MobileKeysReader *)reader openingType:(MobileKeysOpeningType)type openingStatus:(MobileKeysOpeningStatusType)status;

 /**
 * Callback for when the application disconnected the reader.
 * @param reader - The reader which application has disconnected from.
 * @param type - The type of opening which initiated the connection attempt.
 * @param result - Status of the failed connection
 * @note since version 4.0
 */
- (void)mobileKeysDidDisconnectFromReader:(MobileKeysReader *)reader openingType:(MobileKeysOpeningType)type openingResult:(MobileKeysOpeningResult *)result;

 /**
 * Decides if application should allow connection to reader. This will be called by the library
 * prior to attempting connect to reader.
 * @param reader - The reader which the application is considering connecting to.
 * @param type - The type of opening which initiated the connection attempt.
 * @note since version 2.0
 */
- (BOOL)mobileKeysShouldAttemptToOpen:(MobileKeysReader *)reader openingType:(MobileKeysOpeningType)type;

@optional

 /**
 * Callback for each advertisement the SDK receives from the readers in the devices vicinity.
 * Return a boolean containing the decision to attempt to open the reader or not.
 * If this callback is implemented, the SDK will call this function on each and every one of the RSSI value measurements,
 * which could impact battery consumption of your application.
 *
 * This is a low-level method that should only be implemented for custom opening behaviors,
 * i.e. not one of the types in `MobileKeysOpeningType`.
 * @param mobileKeysReader - The reader that sent the advertisement
 * @note since version 2.0
 * @deprecated this delegate callback will be moved to `MobileKeysManagerExtendedDelegate`
 */
- (BOOL)mobileKeysShouldInteractWithScannedReader:(MobileKeysReader *)mobileKeysReader DEPRECATED_MSG_ATTRIBUTE("This delegate callback will moved to MobileKeysManagerExtendedDelegate");

 /**
 * Callback for when the user did an unlock gesture.
 *
 * @note since version 2.0
 * @deprecated this delegate callback will be moved to `MobileKeysManagerExtendedDelegate`
 */
- (void)mobileKeysUserDidUnlockGesture DEPRECATED_MSG_ATTRIBUTE("This delegate callback will moved to MobileKeysManagerExtendedDelegate");

@end

