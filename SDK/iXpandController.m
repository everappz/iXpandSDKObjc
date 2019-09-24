//
//  iXpandController.m
//  Everapp
//
//  Created by Artem on 9/20/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#ifdef APP_IXPAND_SUPPORT

#import "iXpandController.h"
#import "IFDFlashDriveItemAttributes.h"
#import "IFDFlashDriveDeviceAttributes.h"
#import "NSError+iXpandController.h"
#import <iXpandSDKlib/iXpandSDKlib.h>
#import <ExternalAccessory/ExternalAccessory.h>

NSString * const iXpandControllerFlashDriveConnectedNotification = @"iXpandControllerFlashDriveConnectedNotification";
NSString * const iXpandControllerFlashDriveDisconnectedNotification = @"iXpandControllerFlashDriveDisconnectedNotification";

#define FSC_LEN_MAXTRANFER          (48 * 1024)
#define MAX_WRITE_BUFFER_SIZE       (FSC_LEN_MAXTRANFER * 10)
#define MAX_APIDATA_SIZE            MAX_WRITE_BUFFER_SIZE
#define MAX_DATABUFFER              (1024 * 480)

#if __has_feature(objc_arc)

#define iXpandWeakifyWithName(reference, weakReferenceName) __weak __typeof(reference) weakReferenceName = reference;
#define iXpandStrongifyWithName(reference, strongReferenceName) __strong __typeof(reference) strongReferenceName = reference;

#else

#define iXpandWeakifyWithName(reference, weakReferenceName) __block __typeof(reference) weakReferenceName = reference;
#define iXpandStrongifyWithName(reference, strongReferenceName) __typeof(reference) strongReferenceName = reference;

#endif

#define iXpandWeakify(reference) iXpandWeakifyWithName(reference, weak_##reference)
#define iXpandStrongify(reference) iXpandStrongifyWithName(reference, strong_##reference)

#define iXpandStrongifyWithNameAndReturnValueIfNil(reference, strongReferenceName, value) \
iXpandStrongifyWithName(reference, strongReferenceName); \
if (nil == strongReferenceName) { \
return (value); \
} \

#define iXpandStrongifyWithNameAndReturnIfNil(reference, strongReferenceName) iXpandStrongifyWithNameAndReturnValueIfNil(reference, strongReferenceName, (void)0)

#define iXpandWeakifySelf iXpandWeakifyWithName(self, weakSelf);
#define iXpandStrongifySelf iXpandWeakifyWithName(weakSelf, strongSelf);

#define iXpandStrongifySelfAndReturnIfNil iXpandStrongifyWithNameAndReturnIfNil(weakSelf,strongSelf);

@interface iXpandController ()<EAAccessoryDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (assign, atomic) BOOL sessionOpened;

@end


@implementation iXpandController

+ (instancetype)sharedController{
    static dispatch_once_t onceToken;
    static iXpandController *controller;
    dispatch_once(&onceToken, ^{
        controller = [[iXpandController alloc] init];
    });
    return controller;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accessoryDidConnect:)
                                                     name:EAAccessoryDidConnectNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accessoryDidDisconnect:)
                                                     name:EAAccessoryDidDisconnectNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accessory Connect/Disconnect Notifications

- (BOOL)isiXpandAccessoryProtocol:(EAAccessory *)accessory{
    NSString *protocol = [[accessory  protocolStrings] firstObject];
    return (([protocol isEqualToString:iXpandFlashDriveV1Protocol]) ||
            ([protocol isEqualToString:iXpandFlashDriveV2Protocol]) ||
            ([protocol isEqualToString:iXpandFlashDriveV3Protocol]) ||
            ([protocol isEqualToString:iXpandFlashDriveV6Protocol]) ||
            ([protocol isEqualToString:iXpandFlashDriveV7Protocol]));
}

- (void)accessoryDidConnect:(NSNotification *)notification{
    EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
    if([self isiXpandAccessoryProtocol:accessory]){
        [[NSNotificationCenter defaultCenter] postNotificationName:iXpandControllerFlashDriveConnectedNotification object:self];
    }
}

- (void)accessoryDidDisconnect:(NSNotification *)notification{
    EAAccessory *accessory = notification.userInfo[EAAccessoryKey];
    if([self isiXpandAccessoryProtocol:accessory]){
        self.sessionOpened = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:iXpandControllerFlashDriveDisconnectedNotification object:self];
    }
}

#pragma mark - IsConnected

- (BOOL)isAccesoryConnectedAndSessionOpened{
    if(self.sessionOpened && self.isAccessoryConnected){
        return YES;
    }
    return NO;
}

- (BOOL)isAccessoryConnected{
    return [self connectediXpandAccessory]!=nil;
}

- (EAAccessory *)connectediXpandAccessory{
    __block EAAccessory *accessory = nil;
    [[[EAAccessoryManager sharedAccessoryManager] connectedAccessories] enumerateObjectsUsingBlock:^(EAAccessory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([self isiXpandAccessoryProtocol:obj]){
            accessory = obj;
        }
    }];
    return accessory;
}

#pragma mark - Open Session

- (NSOperation *)openSessionWithCompletion:(iXpandControllerErrorBlock)completion{
    iXpandWeakifySelf;
    return [self dispatchBlock:^{
        iXpandStrongifySelfAndReturnIfNil;
        if([[[EAAccessoryManager sharedAccessoryManager] connectedAccessories] count] == 0){
            if(completion){
                completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeAccessoryNotConnected]);
            }
            return;
        }
        EAAccessory *accessory = [strongSelf connectediXpandAccessory];
        if(accessory==nil){
            if(completion){
                completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeSanDiskAccessoryNotFound]);
            }
        }
        else{
            [strongSelf _probeConnectedAccessory:accessory completion:completion];
        }
    } priority:NSOperationQueuePriorityHigh];
}

- (void)_probeConnectedAccessory:(EAAccessory *)accessory completion:(iXpandControllerErrorBlock)completion{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block AccessoryCallbacks accStatus;
    [[iXpandSystemController sharedController] checkAccessoryUseFlag:^(AccessoryCallbacks accessoryStatus) {
        accStatus = accessoryStatus;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (accStatus != ACCESSORY_FREE) {
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeAccessoryInUse]);
        }
        return;
    }
    if (![[iXpandSystemController sharedController] initDrive:accessory]) {
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeDriveInitialisationFailed]);
        }
        return;
    }
    BOOL success = [[iXpandSystemController sharedController] openSession];
    if (!success){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeOpenSessionFailed]);
        }
        return;
    }
    self.sessionOpened = YES;
    if(completion){
        completion(nil);
    }
}

#pragma mark - Close Session

- (NSOperation *)closeSessionWithCompletion:(iXpandControllerErrorBlock)completion{
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            [[iXpandSystemController sharedController] closeSession];
            [[iXpandSystemController sharedController] unregisterAccessoryCheck];
            strongSelf.sessionOpened = NO;
            if(completion){
                completion(nil);
            }
        } priority:NSOperationQueuePriorityHigh];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

#pragma mark - Item Attributes

- (NSOperation *)attributesOfItemAtPath:(NSString *)drivePath
                             completion:(iXpandControllerItemAttributesBlock)completion{
    NSParameterAssert(drivePath.length>0);
    if (drivePath.length == 0 ){
        if(completion){
            completion(nil,[NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            NSError *error = nil;
            FILE_ATTRIBUTE attrInternal = [strongSelf _attributesOfItemAtPath:drivePath error:&error];
            if(error==nil){
                NSUInteger fileSize = [strongSelf _driveFileSizeAtPath:drivePath error:NULL];
                IFDFlashDriveItemAttributes *attr = [[IFDFlashDriveItemAttributes alloc] initWithItemName:drivePath.lastPathComponent itemSize:fileSize attributes:attrInternal];
                if(completion){
                    completion(attr,nil);
                }
            }
            else{
                if(completion){
                    completion(nil,error);
                }
            }
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion(nil,[NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (FILE_ATTRIBUTE)_attributesOfItemAtPath:(NSString *)absolutePath
                                    error:(NSError *__autoreleasing *)error{
    FILE_ATTRIBUTE attributes = {0};
    if ([self _testForNilParameters:(absolutePath == nil) error:error]){
        return attributes;
    }
    NSString *originalDirectory = [[iXpandFileSystemController sharedController] getCurrentDirectory];
    if ([self _changeDirectory:[absolutePath stringByDeletingLastPathComponent] error:error]==NO){
        return attributes;
    }
    BOOL getFileAttributesSuccess = NO;
    NSString *fileName = [absolutePath lastPathComponent];
    @autoreleasepool{
        getFileAttributesSuccess = [[iXpandFileSystemController sharedController] getFileAttribute:fileName fileAttribute:&attributes];
    }
    if (getFileAttributesSuccess == NO){
        if (error != NULL){
            *error = [NSError iXpandErrorWithCode:iXpandControllerErrorCodeCannotGetItemAttributes];
        }
    }
    [self _changeDirectory:originalDirectory error:NULL];
    return attributes;
}

- (BOOL)_changeDirectory:(NSString *)directory error:(NSError *__autoreleasing *)error{
    if ([self _testForNilParameters:(directory == nil) error:error]){
        return NO;
    }
    if (![[iXpandFileSystemController sharedController] changeDirectoryAbsolutePath:directory]){
        if (error != NULL){
            *error = [NSError iXpandErrorWithCode:iXpandControllerErrorCodeChangeDirectoryFailed];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Delete Item

- (NSOperation *)deleteItemAtPath:(NSString *)drivePath
                       completion:(iXpandControllerErrorBlock)completion{
    NSParameterAssert(drivePath.length>0);
    if (drivePath.length == 0){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            if([strongSelf _isDirectory:drivePath error:NULL]){
                [strongSelf _deleteContentsOfDirectoryAtPath:drivePath];
            }
            long result = [strongSelf _deleteFileOrEmptyDirectoryAtPath:drivePath];
            if(result == 0){
                if(completion){
                    completion(nil);
                }
            }
            else{
                if(completion){
                    completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeDeleteItemFailed]);
                }
            }
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (void)_deleteContentsOfDirectoryAtPath:(NSString *)drivePath{
    NSArray<NSDictionary *> *contentsOfDirectory = [self _contentsOfDirectoryAtPath:drivePath includeHiddenFiles:YES includeSystemFiles:YES error:NULL];
    NSMutableArray <NSString *> *directories = [NSMutableArray<NSString *> new];
    for (NSDictionary *fileInfo in contentsOfDirectory) {
        NSString *itemName = [fileInfo objectForKey:@"name"];
        NSParameterAssert(itemName.length>0);
        if(itemName.length>0){
            NSString *fullItemPath = [drivePath stringByAppendingPathComponent:itemName];
            if([self _isDirectory:fullItemPath error:NULL]){
                [directories addObject:fullItemPath];
            }
            else{
                [self _deleteFileOrEmptyDirectoryAtPath:fullItemPath];
            }
        }
    }
    [directories enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _deleteContentsOfDirectoryAtPath:obj];
        [self _deleteFileOrEmptyDirectoryAtPath:obj];
    }];
}

- (long)_deleteFileOrEmptyDirectoryAtPath:(NSString *)path{
    long result = -1;
    [[iXpandFileSystemController sharedController] changeDirectoryAbsolutePath:@"/"];
    @autoreleasepool{
        result = [[iXpandFileSystemController sharedController] deleteFileAbsolutePath:path];
    }
    return result;
}

#pragma mark - Move Item

- (NSOperation *)moveItemAtPath:(NSString *)srcDrivePath
                         toPath:(NSString *)dstDrivePath
                     completion:(iXpandControllerErrorBlock)completion{
    NSParameterAssert(srcDrivePath.length>0);
    NSParameterAssert(dstDrivePath.length>0);
    if (srcDrivePath.length == 0 || dstDrivePath.length == 0){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            
            NSString *srcParentDir = [srcDrivePath stringByDeletingLastPathComponent];
            NSString *dstParentDir = [dstDrivePath stringByDeletingLastPathComponent];
            
            //rename
            if([srcParentDir isEqualToString:dstParentDir]){
                BOOL changeDir = [[iXpandFileSystemController sharedController] changeDirectoryAbsolutePath:srcParentDir];
                if(changeDir==NO){
                    if(completion){
                        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeChangeDirectoryFailed]);
                    }
                    return;
                }
                int result = [[iXpandFileSystemController sharedController] renameFile:[srcDrivePath lastPathComponent] toName:[dstDrivePath lastPathComponent]];
                if(result==0){
                    if(completion){
                        completion(nil);
                    }
                }
                else{
                    if(completion){
                        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeMoveItemFailed]);
                    }
                }
            }
            //move
            else{
                BOOL changeDir = [[iXpandFileSystemController sharedController] changeDirectoryAbsolutePath:@"/"];
                if(changeDir==NO){
                    if(completion){
                        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeChangeDirectoryFailed]);
                    }
                    return;
                }
                BOOL result = [[iXpandFileSystemController sharedController] movePath:srcDrivePath destination:[dstDrivePath stringByDeletingLastPathComponent]];
                if(result){
                    if(completion){
                        completion(nil);
                    }
                }
                else{
                    if(completion){
                        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeMoveItemFailed]);
                    }
                }
            }
            
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

#pragma mark - Write

- (NSOperation *)writeFileToDriveAtPath:(NSString *)drivePath
                          fromLocalPath:(NSString *)localSystemPath
                               progress:(iXpandControllerProgressBlock)progress
                             completion:(iXpandControllerErrorBlock)completion{
    NSParameterAssert(drivePath.length>0);
    NSParameterAssert(localSystemPath.length>0);
    if (drivePath.length == 0 || localSystemPath.length==0){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            [strongSelf _writeDataToFileAtPath:drivePath
                                 fromLocalPath:localSystemPath
                                      progress:progress
                                    completion:completion];
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (BOOL)_writeDataToFileAtPath:(NSString *)path
                 fromLocalPath:(NSString *)localPath
                      progress:(iXpandControllerProgressBlock)progress
                    completion:(iXpandControllerErrorBlock)completion{
    
    if([[NSFileManager defaultManager] fileExistsAtPath:localPath]==NO){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeFileDoesNotExists]);
        }
        return NO;
    }
    
    NSString *driveParentDirectoryPath = [path stringByDeletingLastPathComponent];
    if ( [self _directoryExistsAtPath:driveParentDirectoryPath error:nil] == NO ){
        [[iXpandFileSystemController sharedController] changeDirectoryAbsolutePath:@"/"];
        if([[iXpandFileSystemController sharedController] createDirectoryAbsolutePath:driveParentDirectoryPath]==NO){
            if(completion){
                completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCreateDirectoryFailed]);
            }
            return NO;
        }
    }
    
    long driveFileHandle = [self _openFileAtPath:path mode:OF_CREATE | OF_WRITE];
    if (driveFileHandle == -1){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCreateFileFailed]);
        }
        return NO;
    }
    
    BOOL success = NO;
    BOOL cancelled = NO;
    BOOL fileReadError = NO;
    BOOL fileWriteError = NO;
    
    NSFileHandle *localSystemFileHandle = [NSFileHandle fileHandleForReadingAtPath:localPath];
    
    uint32_t writeDataLength = 0;
    uint32_t chunkDataLength = 0;
    uint64_t totalCompletedDataLength = 0;
    uint64_t totalDataLength = [self _localSystemFileSize:localPath error:NULL];
    uint64_t totalRemainingDataLength = totalDataLength;
    
    if(totalDataLength>0){
        while((writeDataLength != -1) && (totalRemainingDataLength > 0 && totalRemainingDataLength != -1)){
            @autoreleasepool {
                chunkDataLength = ((totalRemainingDataLength > MAX_DATABUFFER) ? MAX_DATABUFFER : totalRemainingDataLength);
                NSData *localSystemFileDataChunk = nil;
                @try{
                    localSystemFileDataChunk = [localSystemFileHandle readDataOfLength:chunkDataLength];
                }
                @catch(NSException *exc){
                    fileReadError = YES;
                }
                if(localSystemFileDataChunk==nil){
                    fileReadError = YES;
                }
                if(fileReadError){
                    break;
                }
                NSUInteger localSystemFileDataChunkLengh = localSystemFileDataChunk.length;
                writeDataLength = [[iXpandFileSystemController sharedController] writeFile:driveFileHandle
                                                                                  writeBuf:localSystemFileDataChunk
                                                                                 writeSize:localSystemFileDataChunkLengh];
                if(writeDataLength==-1){
                    fileWriteError = YES;
                    break;
                }
                totalCompletedDataLength += writeDataLength;
                totalRemainingDataLength -= writeDataLength;
                BOOL shouldContinue = YES;
                if(progress){
                    shouldContinue = progress((float)totalCompletedDataLength/(float)totalDataLength);
                }
                if(shouldContinue==NO){
                    cancelled = YES;
                    break;
                }
            }
        }
    }
    
    [self _closeFileWithHandle:driveFileHandle];
    @try{[localSystemFileHandle closeFile];}@catch(NSException *exc){}
    success = (fileWriteError==NO && cancelled==NO && fileReadError==NO);
    
    if(completion){
        if(cancelled){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCancelled]);
        }
        else if(success){
            completion(nil);
        }
        else{
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeWriteFileFailed]);
        }
    }
    
    return success;
}

- (long)_openFileAtPath:(NSString *)path mode:(uint8_t)mode{
    long handle = -1;
    if([[iXpandFileSystemController sharedController] changeDirectoryAbsolutePath:@"/"]){
        @autoreleasepool{
            handle = [[iXpandFileSystemController sharedController] openFileAbsolutePath:path openMode:mode];
        }
    }
    return handle;
}

- (void)_closeFileWithHandle:(long)handle{
    if(handle!=-1){
        [[iXpandFileSystemController sharedController] closeFile:handle];
    }
}

- (uint64_t)_localSystemFileSize:(NSString *)filePath error:(NSError *__autoreleasing *)error{
    uint64_t uintFileSize = -1;
    if ([self _testForNilParameters:(filePath == nil) error:error]){
        return uintFileSize;
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]){
        NSDictionary *nsdFile = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        uintFileSize = [nsdFile fileSize];
    }
    else{
        if (error != NULL){
            *error = [NSError iXpandErrorWithCode:iXpandControllerErrorCodeFileDoesNotExists];
        }
    }
    return uintFileSize;
}

- (uint64_t)_driveFileSize:(long)handle{
    uint64_t uintFileSize = -1;
    if(handle!=-1){
        uintFileSize = [[iXpandFileSystemController sharedController] getFileSize:handle];
    }
    return uintFileSize;
}

- (uint64_t)_driveFileSizeAtPath:(NSString *)drivePath error:(NSError *__autoreleasing *)error{
    uint64_t uintFileSize = -1;
    if ([self _testForNilParameters:(drivePath == nil) error:error]){
        return uintFileSize;
    }
    long driveFileHandle = [self _openFileAtPath:drivePath mode:OF_READ];
    if (driveFileHandle != -1){
        uintFileSize = [self _driveFileSize:driveFileHandle];
    }
    [self _closeFileWithHandle:driveFileHandle];
    return uintFileSize;
}

#pragma mark - Read

- (NSOperation *)readFileFromDriveAtPath:(NSString *)drivePath
                             toLocalPath:(NSString *)localSystemPath
                                progress:(iXpandControllerProgressBlock)progress
                              completion:(iXpandControllerErrorBlock)completion{
    NSParameterAssert(drivePath.length>0);
    NSParameterAssert(localSystemPath.length>0);
    if (drivePath.length == 0 || localSystemPath.length==0){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            [strongSelf _readDataFromDriveAtPath:drivePath
                                     toLocalPath:localSystemPath
                                        progress:progress
                                      completion:completion];
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (BOOL)_readDataFromDriveAtPath:(NSString *)drivePath
                     toLocalPath:(NSString *)localSystemPath
                        progress:(iXpandControllerProgressBlock)progress
                      completion:(iXpandControllerErrorBlock)completion{
    
    long driveFileHandle = [self _openFileAtPath:drivePath mode:OF_READ];
    if (driveFileHandle == -1){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeOpenFileFailed]);
        }
        return NO;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:localSystemPath isDirectory:nil]){
        [[NSFileManager defaultManager] removeItemAtPath:localSystemPath error:nil];
    }
    
    BOOL createFileSuccess = [[NSFileManager defaultManager] createFileAtPath:localSystemPath contents:nil attributes:nil];
    if(createFileSuccess==NO){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCreateFileFailed]);
        }
        return NO;
    }
    
    NSFileHandle *localSystemFileHandle = [NSFileHandle fileHandleForWritingAtPath:localSystemPath];
    uint64_t totalDataLen = [self _driveFileSize:driveFileHandle];
    
    BOOL success = NO;
    BOOL cancelled = NO;
    BOOL fileReadError = NO;
    BOOL fileWriteError = NO;
    
    if(totalDataLen>0){
        
        uint32_t readDataLen = 0;
        uint32_t totalCompletedDataLength = 0;
        
        do{
            @autoreleasepool {
                NSData *readBuffer = [NSMutableData dataWithBytesNoCopy:malloc(MAX_DATABUFFER) length:MAX_DATABUFFER];
                readDataLen = [[iXpandFileSystemController sharedController] readFile:driveFileHandle readBuf:readBuffer readSize:MAX_DATABUFFER];
                if((readDataLen != -1) && (readDataLen != 0)){
                    NSData *dataToWrite = [NSData dataWithBytes:[readBuffer bytes] length:readDataLen];
                    BOOL writeSuccess = YES;
                    @try{
                        [localSystemFileHandle writeData:dataToWrite];
                    }
                    @catch(NSException *exc){
                        writeSuccess = NO;
                    }
                    if(writeSuccess==NO){
                        fileWriteError = YES;
                        break;
                    }
                    
                    totalCompletedDataLength+=readDataLen;
                    BOOL shouldContinue = YES;
                    if(progress){
                        shouldContinue = progress((float)totalCompletedDataLength/(float)totalDataLen);
                    }
                    if(shouldContinue==NO){
                        cancelled = YES;
                        break;
                    }
                }
                else{
                    if (readDataLen == -1){
                        fileReadError = YES;
                    }
                    break;
                }
            }
        } while((readDataLen != -1) && (readDataLen != 0));
        
    }
    
    [self _closeFileWithHandle:driveFileHandle];
    @try {[localSystemFileHandle closeFile];} @catch (NSException *exception) {}
    success = (fileWriteError==NO && cancelled==NO && fileReadError==NO);
    
    if(completion){
        if(cancelled){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCancelled]);
        }
        else if(success){
            completion(nil);
        }
        else{
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeReadFileFailed]);
        }
    }
    
    return success;
    
}

#pragma mark - Read Data

- (NSOperation *)readFileFromDriveAtPath:(NSString *)drivePath
                                  offset:(uint64_t)offset
                                progress:(iXpandControllerDataBlock)progress
                              completion:(iXpandControllerErrorBlock)completion{
    NSParameterAssert(drivePath.length>0);
    if (drivePath.length == 0){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            [strongSelf _readDataFromDriveAtPath:drivePath
                                          offset:offset
                                        progress:progress
                                      completion:completion];
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (BOOL)_readDataFromDriveAtPath:(NSString *)drivePath
                          offset:(uint64_t)offset
                        progress:(iXpandControllerDataBlock)progress
                      completion:(iXpandControllerErrorBlock)completion{
    
    long driveFileHandle = [self _openFileAtPath:drivePath mode:OF_READ];
    if (driveFileHandle == -1){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeOpenFileFailed]);
        }
        return NO;
    }
    
    uint64_t totalDataLen = [self _driveFileSize:driveFileHandle];
    
    BOOL success = NO;
    BOOL cancelled = NO;
    BOOL fileReadError = NO;
    BOOL fileSeekError = NO;
    
    if(totalDataLen>0){
        uint32_t readDataLen = 0;
        DWORD seekResult = [[iXpandFileSystemController sharedController] seekFile:driveFileHandle seekPosition:offset];
        if(seekResult==-1){
            fileSeekError = YES;
        }
        else{
            do{
                @autoreleasepool {
                    NSData *readBuffer = [NSMutableData dataWithBytesNoCopy:malloc(MAX_DATABUFFER) length:MAX_DATABUFFER];
                    readDataLen = [[iXpandFileSystemController sharedController] readFile:driveFileHandle readBuf:readBuffer readSize:MAX_DATABUFFER];
                    if((readDataLen != -1) && (readDataLen != 0)){
                        NSData *dataToWrite = [NSData dataWithBytes:[readBuffer bytes] length:readDataLen];
                        BOOL shouldContinue = YES;
                        if(progress){
                            shouldContinue = progress(dataToWrite);
                        }
                        if(shouldContinue==NO){
                            cancelled = YES;
                            break;
                        }
                    }
                    else{
                        if (readDataLen == -1){
                            fileReadError = YES;
                        }
                        break;
                    }
                }
            } while((readDataLen != -1) && (readDataLen != 0));
        }
    }
    
    [self _closeFileWithHandle:driveFileHandle];
    
    success = (cancelled==NO && fileReadError==NO && fileSeekError==NO);
    
    if(completion){
        if(cancelled){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCancelled]);
        }
        else if(fileSeekError){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeSeekFileFailed]);
        }
        else if(success){
            completion(nil);
        }
        else{
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeReadFileFailed]);
        }
    }
    
    return success;
    
}

#pragma mark - Create Directory

- (NSOperation *)createDirectoryAtPath:(NSString *)drivePath
                            completion:(iXpandControllerErrorBlock)completion{
    NSParameterAssert(drivePath.length>0);
    if (drivePath.length == 0){
        if(completion){
            completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            if ([strongSelf _directoryExistsAtPath:drivePath error:NULL]){
                if(completion){
                    completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeDirectoryAlreadyExists]);
                }
                return;
            }
            if([[iXpandFileSystemController sharedController] createDirectoryAbsolutePath:drivePath]){
                if(completion){
                    completion(nil);
                }
            }
            else{
                if(completion){
                    completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeCreateDirectoryFailed]);
                }
            }
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion([NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (BOOL)_directoryExistsAtPath:(NSString *)path
                         error:(NSError *__autoreleasing *)error{
    if ([self _testForNilParameters:(path == nil) error:error]){
        return NO;
    }
    return [self _isDirectory:path error:NULL];
}

- (BOOL)_isDirectory:(NSString *)path
               error:(NSError *__autoreleasing *)error{
    FILE_ATTRIBUTE attributes = [self _attributesOfItemAtPath:path error:error];
    return ((attributes.attributes & FA_DIREC) !=0);
}

#pragma mark - Device Attributes

- (NSOperation *)deviceAttributesWithCompletion:(iXpandControllerDeviceAttributesBlock)completion{
    iXpandWeakifySelf;
    return [self dispatchBlock:^{
        iXpandStrongifySelfAndReturnIfNil;
        IFDFlashDriveDeviceAttributes *attributes = [[IFDFlashDriveDeviceAttributes alloc] init];
        attributes.FATType = [[iXpandFileSystemController sharedController] getFATType];
        attributes.label = [[iXpandFileSystemController sharedController] getLabel];
        attributes.totalAvailableSpace = [[iXpandFileSystemController sharedController] getTotalAvailableSpace];
        attributes.availableSpace = [[iXpandFileSystemController sharedController] getAvailableSpace];
        attributes.deviceType = [[iXpandSystemController sharedController] getDeviceType];
        attributes.batteryState = [[iXpandSystemController sharedController] getBatteryState];
        attributes.deviceFwVersion = [[iXpandSystemController sharedController] getDeviceFwVersion];
        if(completion){
            completion(attributes,nil);
        }
    } priority:NSOperationQueuePriorityNormal];
}

#pragma mark - Contents of Directory

- (NSOperation *)contentsOfDirectoryAtPath:(NSString *)drivePath
                        includeHiddenFiles:(BOOL)includeHidden
                        includeSystemFiles:(BOOL)includeSystem
                                completion:(iXpandControllerContentsOfDirectoryBlock)completion{
    NSParameterAssert(drivePath.length>0);
    if (drivePath.length == 0){
        if(completion){
            completion(nil,[NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters]);
        }
        return nil;
    }
    if([self isAccesoryConnectedAndSessionOpened]){
        iXpandWeakifySelf;
        return [self dispatchBlock:^{
            iXpandStrongifySelfAndReturnIfNil;
            NSError *__autoreleasing *error = nil;
            NSArray<NSDictionary *> *directoryContent = [strongSelf _contentsOfDirectoryAtPath:drivePath
                                                                            includeHiddenFiles:includeHidden
                                                                            includeSystemFiles:includeSystem
                                                                                         error:error];
            if (directoryContent.count) {
                NSMutableArray <IFDFlashDriveItemAttributes *> *attrArray = [[NSMutableArray<IFDFlashDriveItemAttributes *> alloc] initWithCapacity:directoryContent.count];
                for (NSDictionary *fileInfo in directoryContent) {
                    NSString *itemName = [fileInfo objectForKey:@"name"];
                    NSNumber *itemSize = [fileInfo objectForKey:@"size"];
                    NSCParameterAssert(itemName.length>0);
                    NSCParameterAssert(itemSize);
                    if(itemName.length>0){
                        NSString *itemPath = [drivePath stringByAppendingPathComponent:itemName];
                        FILE_ATTRIBUTE attributes = [strongSelf _attributesOfItemAtPath:itemPath error:NULL];
                        IFDFlashDriveItemAttributes *attrObj = [[IFDFlashDriveItemAttributes alloc] initWithItemName:itemName itemSize:[itemSize unsignedIntegerValue] attributes:attributes];
                        if(attrObj){
                            [attrArray addObject:attrObj];
                        }
                    }
                }
                if(completion){
                    completion(attrArray,nil);
                }
            }
            else{
                if(completion){
                    completion(nil,nil);
                }
            }
        } priority:NSOperationQueuePriorityNormal];
    }
    if(completion){
        completion(nil,[NSError iXpandErrorWithCode:iXpandControllerErrorCodeNoAccessoryOrNoActiveSession]);
    }
    return nil;
}

- (NSArray<NSDictionary *> *)_contentsOfDirectoryAtPath:(NSString *)path
                                     includeHiddenFiles:(BOOL)includeHidden
                                     includeSystemFiles:(BOOL)includeSystem
                                                  error:(NSError *__autoreleasing *)error{
    if ([self _testForNilParameters:([path length] == 0) error:error]){
        return nil;
    }
    iXpandFileSystemController *fileSystem = [iXpandFileSystemController sharedController];
    NSString *originalDirectory = [fileSystem getCurrentDirectory];
    if (![self _changeDirectory:path error:error]){
        return nil;
    }
    
    FFBLK ffblk;
    if ([fileSystem findFirst:@"" findFirstStruct:&ffblk findFirstExact:NO] == 0){
        [self _changeDirectory:originalDirectory error:error];
        return @[];
    }
    
    NSMutableArray<NSDictionary *> *contents = [[NSMutableArray<NSDictionary *> alloc] init];
    
    do{
        if (ffblk.bAttributes == FA_LONGFILENAME){
            continue;
        }
        if (!includeHidden && (ffblk.bAttributes & FA_HIDDEN) != 0){
            continue;
        }
        if (!includeSystem && (ffblk.bAttributes & FA_SYSTEM) != 0){
            continue;
        }
        
        NSString *filename;
        if ([fileSystem.longFileName isEqualToString:@""]){
            NSUInteger length = [fileSystem findStringEnd:ffblk.sFileName length:sizeof(ffblk.sFileName)];
            filename = [[NSString alloc] initWithBytes:ffblk.sFileName length:length encoding:NSASCIIStringEncoding];
        }
        else{
            filename = [NSString stringWithString:fileSystem.longFileName];
        }
        
        if ([filename length] == 0 || [filename isEqualToString:@"."] || [filename isEqualToString:@".."]){
            continue;
        }
        
        if ([filename length] > 0 && !includeHidden && [filename hasPrefix:@"."]){
            continue;
        }
        
        if(filename.length>0){
            NSUInteger fileSize = ffblk.dwFileSize;
            [contents addObject:@{@"name":filename,@"size":@(fileSize)}];
        }
        
    }
    while ([fileSystem findNext:&ffblk] != 0);
    
    [self _changeDirectory:originalDirectory error:error];
    
    return contents;
}

- (BOOL)_testForNilParameters:(BOOL)logicalOR
                        error:(NSError *__autoreleasing *)error{
    if (logicalOR){
        if (error != NULL){
            *error = [NSError iXpandErrorWithCode:iXpandControllerErrorCodeBadInputParameters];
        }
        return YES;
    }
    return NO;
}

#pragma mark - Queue Setup

- (NSOperation *)dispatchBlock:(dispatch_block_t)block
                      priority:(NSOperationQueuePriority)priority{
    NSParameterAssert(block);
    if(block){
        NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            @try {
                if(block){
                    block();
                }
            } @catch (NSException *exception) {}
        }];
        operation.queuePriority = priority;
        [self.operationQueue addOperation:operation];
        return operation;
    }
    return nil;
}

@end

#endif
