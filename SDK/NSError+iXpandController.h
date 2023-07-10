//
//  NSError+iXpandController.h
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#if !(TARGET_OS_SIMULATOR) && !(TARGET_OS_MACCATALYST)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, iXpandControllerErrorCode) {
    
    iXpandControllerErrorCodeCancelled = -999,
    
    iXpandControllerErrorCodeNone = 0,
    
    //Open Session
    iXpandControllerErrorCodeAccessoryInUse,
    iXpandControllerErrorCodeDriveInitialisationFailed,
    iXpandControllerErrorCodeAccessoryNotConnected,
    iXpandControllerErrorCodeSanDiskAccessoryNotFound,
    iXpandControllerErrorCodeOpenSessionFailed,
    
    //Request Parameters
    iXpandControllerErrorCodeBadInputParameters,
    iXpandControllerErrorCodeNoAccessoryOrNoActiveSession,
    
    //Item
    iXpandControllerErrorCodeCannotGetItemAttributes,
    iXpandControllerErrorCodeDeleteItemFailed,
    iXpandControllerErrorCodeMoveItemFailed,
    
    //File
    iXpandControllerErrorCodeFileAlreadyExists,
    iXpandControllerErrorCodeFileDoesNotExists,
    iXpandControllerErrorCodeCreateFileFailed,
    iXpandControllerErrorCodeOpenFileFailed,
    iXpandControllerErrorCodeWriteFileFailed,
    iXpandControllerErrorCodeReadFileFailed,
    iXpandControllerErrorCodeSeekFileFailed,
    
    //Directory
    iXpandControllerErrorCodeCreateDirectoryFailed,
    iXpandControllerErrorCodeDeleteDirectoryFailed,
    iXpandControllerErrorCodeDirectoryAlreadyExists,
    iXpandControllerErrorCodeDirectoryDoesNotExists,
    iXpandControllerErrorCodeChangeDirectoryFailed,
    
};

extern  NSString * const iXpandControllerErrorDomain;

@interface NSError(iXpandController)

+ (instancetype)iXpandErrorWithCode:(iXpandControllerErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END

#endif
