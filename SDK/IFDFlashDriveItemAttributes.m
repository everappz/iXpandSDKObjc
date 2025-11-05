//
//  IFDFlashDriveItemAttributes.m
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#if !TARGET_OS_SIMULATOR && !defined(IXPAND_DISABLED_SIM)

#import "IFDFlashDriveItemAttributes.h"
#import "NSDate+iXpandController.h"


@interface IFDFlashDriveItemAttributes()

@property (copy, nonatomic) NSString *itemName;
@property (assign, nonatomic) uint16_t flags;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *modificationDate;
@property (strong, nonatomic) NSDate *accessDate;
@property (assign, nonatomic) NSUInteger itemSize;

@end

@implementation IFDFlashDriveItemAttributes

- (instancetype)initWithItemName:(NSString *)itemName
                        itemSize:(NSUInteger)itemSize
                      attributes:(FILE_ATTRIBUTE)fileAttr{
    self = [super init];
    if(self){
        self.itemName = itemName;
        self.itemSize = itemSize;
        [self applyFileAttribute:fileAttr];
    }
    return self;
}

- (void)applyFileAttribute:(FILE_ATTRIBUTE)fileAttr{
    self.flags = fileAttr.attributes;
    self.creationDate = [NSDate iXpandDateWithMSDOSDate:fileAttr.creationDate time:fileAttr.creationTime];
    self.modificationDate = [NSDate iXpandDateWithMSDOSDate:fileAttr.modificationDate time:fileAttr.modificationTime];
    self.accessDate = [NSDate iXpandDateWithMSDOSDate:fileAttr.accessDate time:fileAttr.accessTime];
}

- (BOOL)isReadOnly{
    return (self.flags & FA_RDONLY) != 0;
}

- (BOOL)isDirectory{
    return (self.flags & FA_DIREC) != 0;
}

- (BOOL)isArchive{
    return (self.flags & FA_ARCH) != 0;
}

- (BOOL)isSystemFile{
    return (self.flags & FA_SYSTEM) != 0;
}

- (BOOL)isHidden{
    return (self.flags & FA_HIDDEN) != 0;
}

@end

#endif


