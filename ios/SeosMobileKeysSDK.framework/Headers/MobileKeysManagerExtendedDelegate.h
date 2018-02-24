// MobileKeysManagerExtendedDelegate.h
// Copyright (c) 2017 ASSA ABLOY Mobile Services ( http://assaabloy.com/seos )
//
// All rights reserved.

#import "MobileKeysManagerDelegate.h"

/**
 * Extension delegate of `MobileKeysManagerDelegate`
 * @warning this delegate extension is only for advanced use cases. Please consider this before using this delegate.
 * For instance, the tap use case is already supported by the SDK by simply passing `MobileKeysOpeningTypeProximity` to
 * `-[MobileKeysManager startReaderScanInMode:supportedOpeningTypes:lockServiceCodes:error:]`.
 */
@protocol MobileKeysManagerExtendedDelegate <MobileKeysManagerDelegate>

/**
* Callback for each advertisement the SDK receives from the readers in the devices vicinity.
* Return a boolean containing the decision to attempt to open the reader or not.
* If this callback is implemented, the SDK will call this function on each and every RSSI value measurements,
* which could impact battery consumption of your application.
*
* @warning This is a low-level method that should only be implemented for custom opening behaviors,
* i.e. not one of the types in `MobileKeysOpeningType`.
* @param mobileKeysReader - The reader that sent the advertisement
* @note since version 5.1
*/
- (BOOL)mobileKeysShouldInteractWithScannedReader:(MobileKeysReader *)mobileKeysReader;

/**
* Callback for when the user did an unlock gesture.
*
* @note since version 5.1
*/
- (void)mobileKeysUserDidUnlockGesture;
@end
