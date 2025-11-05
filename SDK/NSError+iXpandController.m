//
//  NSError+iXpandController.m
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#if !TARGET_OS_SIMULATOR && !defined(IXPAND_DISABLED_SIM)

#import "NSError+iXpandController.h"

NSString * const iXpandControllerErrorDomain = @"iXpandControllerErrorDomain";

@implementation NSError(iXpandController)

+ (instancetype)iXpandErrorWithCode:(iXpandControllerErrorCode)errorCode{
    return [NSError errorWithDomain:iXpandControllerErrorDomain code:errorCode userInfo:nil];
}

@end

#endif
