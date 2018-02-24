// MobileKeysOpeningResult.h
// Copyright (c) 2014 ASSA ABLOY Mobile Services ( http://assaabloy.com/seos )
//
// All rights reserved.

#import <Foundation/Foundation.h>
#import "MobileKeysReader.h"

/**
 * This class represents the result of a reader opening.
 */
@interface MobileKeysOpeningResult : NSObject

/**
 * Status of the connection
 */
@property(nonatomic) MobileKeysOpeningStatusType status;

/**
 * Opening status payload. EOT fragmend body. Application specific data that was returned from the lock.
 *
* @return additional payload related to the opening, default is nil.
 */
@property(nonatomic) NSData *statusPayload;

@end
