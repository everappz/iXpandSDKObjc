//
//  iXpandSystemAPI.h
//  iXpandSDK
//
//  (C) Copyright 2019 SanDisk, a Western Digital Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iXpandDefinitions.h"

@class EAAccessory;

@interface iXpandSystemController : NSObject

/*!
 * @discussion Init or share the FileSystemController
*/
+ (iXpandSystemController *)sharedController;

/*!
 * @discussion Get current SDK version
 * @return
 * false	SDK version
 */

+ (NSString *)getSDKVersion;

/*!
 * @discussion Initialize the drive, including the file system. Allocate appropriate resources, threads etc.
 * @return
 * false	Operation failed.
 * true     Operation successful.
 */

- (BOOL)initDrive:(EAAccessory *)accessory;

/*!
 * @discussion YES/NO according to, whether the drive is connected or not respectively.
 * @return
 * false	drive isn't connected.
 * true     drive is connected.
 */

- (BOOL)isDriveConnected;

/*!
 * @discussion Open a device session.
 * @return
 * false	Operation failed.
 * true     Operation successful.
 */

- (BOOL)openSession;

/*!
 * @discussion Close a device session.
 * @return
 * false	Operation failed.
 * true     Operation successful.
 */
- (void)closeSession;

/**
 *  Call this method in order to request the access to connected accessory.
 *  Based on returned value, specify corresponding behaviour of your application.
 *
 *  @param accessoryAvailabilityCallback Callback block which will be called after receiving current accessory state.
 */

- (void)checkAccessoryUseFlag:(AccessoryCallback)accessoryAvailabilityCallback;

/**
 *  Call this method to finish use of accessory.
 *  Other applications based on iXpand SDK will be notified that accessory have been released.
 */

- (void)unregisterAccessoryCheck;

/*!
 * @discussion Though an accessory can be interpreted as NOT in use if the timestamp difference is greater than 5 seconds, this API explicitly clears the appString and timestamp values.
 * @param appString Identifier string of the calling app. Set to NULL
 * @param timeStamp Set this to NULL
 * @return
 * false	Operation failed.
 * true     Operation successful.
 */


- (BOOL)wasDriveWrittenFromPC;

// Clear the flag used by wasWrittenByPC.
// Output: Success/Fail.
/*!
 * @discussion Clear the flag used by wasWrittenByPC.
 * @return
 * false	Operation failed.
 * true     Operation successful.
 */
- (BOOL)clearWrittenByPC;

/**
 *  Device type V1 or V2
 *
 *  @return current device type
 */
- (iXpandSupportedDeviceType)getDeviceType;

/*!
 * @discussion Returns the battery level of the accessory.
 * @return
 * -1	Fail
 * 25	0~25%
 * 50	26~50%
 * 75	51~75%
 * 100	76~100%
 */

- (NSInteger)getBatteryState;

/*!
 * @discussion Get the firmware version of the connected device
 * @return Firmware version number
 */

- (NSString *)getDeviceFwVersion;

@end
