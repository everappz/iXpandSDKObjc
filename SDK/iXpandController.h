//
//  iXpandController.h
//  Everapp
//
//  Created by Artem on 9/20/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#ifdef APP_IXPAND_SUPPORT

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IFDFlashDriveDeviceAttributes;
@class IFDFlashDriveItemAttributes;
@class EAAccessory;

extern NSString * const iXpandControllerFlashDriveConnectedNotification;
extern NSString * const iXpandControllerFlashDriveDisconnectedNotification;

typedef void(^iXpandControllerErrorBlock)(NSError * _Nullable error);
typedef void(^iXpandControllerDeviceAttributesBlock)(IFDFlashDriveDeviceAttributes * _Nullable attributes,NSError * _Nullable error);
typedef void(^iXpandControllerContentsOfDirectoryBlock)(NSArray <IFDFlashDriveItemAttributes *> * _Nullable attributes,NSError * _Nullable error);
typedef void(^iXpandControllerItemAttributesBlock)(IFDFlashDriveItemAttributes * _Nullable attributes,NSError * _Nullable error);
typedef BOOL(^iXpandControllerProgressBlock)(float progress);
typedef BOOL(^iXpandControllerDataBlock)(NSData * _Nonnull data);

@interface iXpandController : NSObject

+ (instancetype)sharedController;

- (BOOL)isAccesoryConnectedAndSessionOpened;

- (BOOL)isAccessoryConnected;

- (EAAccessory *)connectediXpandAccessory;

- (NSOperation *)openSessionWithTimeout:(NSTimeInterval)timeout completion:(nullable iXpandControllerErrorBlock)completion;

- (NSOperation * _Nullable)closeSessionWithCompletion:(nullable iXpandControllerErrorBlock)completion;

- (NSOperation * _Nullable)attributesOfItemAtPath:(NSString *)drivePath
                                       completion:(nullable iXpandControllerItemAttributesBlock)completion;

- (NSOperation *)moveItemAtPath:(NSString *)srcDrivePath
                         toPath:(NSString *)dstDrivePath
                     completion:(iXpandControllerErrorBlock)completion;

- (NSOperation * _Nullable)writeFileToDriveAtPath:(NSString *)drivePath
                                    fromLocalPath:(NSString *)localSystemPath
                                         progress:(nullable iXpandControllerProgressBlock)progress
                                       completion:(nullable iXpandControllerErrorBlock)completion;

- (NSOperation * _Nullable)readFileFromDriveAtPath:(NSString *)drivePath
                                       toLocalPath:(NSString *)localSystemPath
                                          progress:(nullable iXpandControllerProgressBlock)progress
                                        completion:(nullable iXpandControllerErrorBlock)completion;

- (NSOperation *)readFileFromDriveAtPath:(NSString *)drivePath
                                  offset:(uint64_t)offset
                                progress:(nullable iXpandControllerDataBlock)progress
                              completion:(nullable iXpandControllerErrorBlock)completion;

- (NSOperation * _Nullable)createDirectoryAtPath:(NSString *)drivePath
                                      completion:(nullable iXpandControllerErrorBlock)completion;

- (NSOperation * _Nullable)deviceAttributesWithCompletion:(nullable iXpandControllerDeviceAttributesBlock)completion;

- (NSOperation * _Nullable)contentsOfDirectoryAtPath:(NSString *)drivePath
                                  includeHiddenFiles:(BOOL)includeHidden
                                  includeSystemFiles:(BOOL)includeSystem
                                          completion:(nullable iXpandControllerContentsOfDirectoryBlock)completion;

- (NSOperation * _Nullable)deleteItemAtPath:(NSString *)drivePath
                                 completion:(nullable iXpandControllerErrorBlock)completion;

@end

NS_ASSUME_NONNULL_END

#endif
