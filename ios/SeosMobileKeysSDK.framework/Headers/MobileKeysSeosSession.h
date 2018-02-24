// MobileKeysSeosSession.h
// Copyright (c) 2016 ASSA ABLOY Mobile Services ( http://assaabloy.com/seos )
//
// All rights reserved

#import "MobileKeysApduResponse.h"
#import "MobileKeysApduCommand.h"
#import "MobileKeysApduConnectionProtocol.h"

/**
 * Configuration enum to perform the session over contact or contactless
 */
typedef NS_ENUM(NSUInteger, MobileKeysSeosSessionType) {
    /**
     * Contact session
     */
    MobileKeysSeosSessionTypeContact = 1,
    /**
     * Contactless session
     */
    MobileKeysSeosSessionTypeContactless = 2,
};

/**
 * For Mobile Access SDK 5.0.0, you normally do not use this class directly. Use the MobileKeysSeosProvider instead, as
 * that class takes care of ADF Selection, Mutual Authentication and session management.
 *
 * @note since version 5.0.0
 */
@interface MobileKeysSeosSession : NSObject

@property(nonatomic) BOOL usesSecureMessaging;

/**
 * Constructs a `MobileKeysSeosSession` with the specified `MobileKeysApduConnectionProtocol`
 *
 * @param apduConnection    the APDU connection to use in this session
 * @return                  a session instance
 */
- (instancetype)initWithApduConnection:(id <MobileKeysApduConnectionProtocol>)apduConnection;

/**
 * Sends an APDU command and receives a response from the Seos applet. This method allows the caller to utilize the
 * automatic APDU Command splitting and APDU Respose Joining of the SDK.
 *
 * @param command               the data command to send.
 * @param autoSplit             set this to YES to enable auto split of large apdu commands.
 * @param autoJoin              set this to YES to enable auto join of apdu responses.
 * @param error                 if something went wrong this parameter is set, otherwise nil.
 * @return                      the response from Seos processing the command or nil if something went wrong
 */
- (MobileKeysApduResponse *)processApduCommand:(MobileKeysApduCommand *)command autoSplitLargeApduCommands:(BOOL)autoSplit autoJoinMultipleApduResponses:(BOOL)autoJoin withError:(NSError **)error;

/**
 * Sends an APDU command and receives a response from the Seos applet.
 * This method is deprecated.
 *
 * @param command           the data command to send.
 * @param ignoreChaining        set this to NO to disable honoring the chaining flag.
 * @param error                 if something went wrong this parameter is set, otherwise nil.
 * @return                      the response from Seos processing the command or nil if something went wrong
 * @deprecated since 5.2.0
 */
- (MobileKeysApduResponse *)processApduCommand:(MobileKeysApduCommand *)command ignoreChaining:(BOOL)ignoreChaining withError:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("Use processApduCommand:autoSplitLargeApduCommands:autoJoinMultipleApduResponses:withError: instead");


/**
 * Sends an APDU command and receives a response from the Seos applet.
 *
 * @note Convenience method for `processApduCommand:ignoreChaining:withError` with `ignoreChaining` set to `NO`
 * @param error                 if something went wrong this parameter is set, otherwise nil.
 * @return                      the response from Seos processing the command or nil if something went wrong
 */
- (MobileKeysApduResponse *)processApduCommand:(MobileKeysApduCommand *)apduCommand withError:(NSError **)error;

@end
