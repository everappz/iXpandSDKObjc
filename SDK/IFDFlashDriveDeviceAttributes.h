//
//  IFDFlashDriveDeviceAttributes.h
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFDFlashDriveDeviceAttributes : NSObject

@property (assign, nonatomic) NSInteger FATType;
@property (copy, nonatomic) NSString *label;
@property (assign, nonatomic) uint64_t totalAvailableSpace;
@property (assign, nonatomic) uint64_t availableSpace;
@property (assign, nonatomic) NSInteger deviceType;
@property (assign, nonatomic) NSInteger batteryState;
@property (copy, nonatomic) NSString *deviceFwVersion;

@end

NS_ASSUME_NONNULL_END
