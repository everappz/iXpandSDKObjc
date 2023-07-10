//
//  IFDFlashDriveItemAttributes.h
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iXpandSDKlib/iXpandSDKlib.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFDFlashDriveItemAttributes : NSObject

- (instancetype)initWithItemName:(NSString *)itemName
                        itemSize:(NSUInteger)itemSize
                      attributes:(FILE_ATTRIBUTE)fileAttr;

@property (copy, nonatomic, readonly) NSString *itemName;
@property (assign, nonatomic, readonly) uint16_t flags;
@property (strong, nonatomic, readonly) NSDate *creationDate;
@property (strong, nonatomic, readonly) NSDate *modificationDate;
@property (strong, nonatomic, readonly) NSDate *accessDate;
@property (assign, nonatomic, readonly) NSUInteger itemSize;

- (BOOL)isReadOnly;
- (BOOL)isDirectory;
- (BOOL)isArchive;
- (BOOL)isSystemFile;
- (BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
