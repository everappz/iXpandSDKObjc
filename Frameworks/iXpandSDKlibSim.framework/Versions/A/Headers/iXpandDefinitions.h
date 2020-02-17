//
//  iXpandDefinitions.h
//  iXpandSDK
//
//  (C) Copyright 2019 SanDisk, a Western Digital Company. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include "integer.h"

#define iXpandFlashDriveV1Protocol @"com.sandisk.ixpandflashdrive"
#define iXpandFlashDriveV2Protocol @"com.sandisk.ixpandv2"
#define iXpandFlashDriveV3Protocol @"com.sandisk.ixpandv3"
#define iXpandFlashDriveV6Protocol @"com.sandisk.ixpandv6"
#define iXpandFlashDriveV7Protocol @"com.sandisk.ixpandv7"

//================================================================================
#define MAX_SECTORSIZE              512

#define MAX_FILES                   20

#define EMPTY_STRING                @""
#define SPACE_STRING                @" "
#define DOT_STRING                  @"."
#define DOTDOT_STRING               @".."
#define TILDE_STRING                @"~"
#define ROOT_STRING                 @"\\"

#define IFDISKBATTERY           @"iFDiskBattery"
#define BATTERY_LOWPOWER        @"lowPower"

#define TYPE_OTA_TOOL     @"OTA Tool"
#define TYPE_FW_APP       @"Firmware Application"

#define UNKNOWN_FIRMWARE_VERSION @"-1"

enum {
    OTA_BIN_UPDATE_SUCCESS = 0,
    OTA_BIN_FILE_ERROR,
    OTA_DEVICE_VERSION_IS_LATEST,
    OTA_BIN_FILE_IS_OLDER,
    OTA_BIN_FILE_VERSION_NOT_SUPPORT,
    OTA_BIN_FILE_IS_NOT_FW_CODE,
    OTA_BIN_FILE_IS_NOT_TOOL_CODE,
    OTA_ISP_CHECK_TOOL_FAIL,
    OTA_ISP_WRITE_TOOL_FAIL,
    OTA_ISP_CHECK_FW_FAIL,
    OTA_ISP_WRITE_FW_FAIL,
    OTA_ISP_ERASE_TOOL_FAIL,
    OTA_ISP_ERASE_FW_FAIL,
    OTA_ACCESSORY_REMOVED,
    OTA_JUMP_TOOL_FAIL,
    OTA_JUMP_FW_FAIL,
};

//================================================================================

static uint8_t fileFlagsInvalid = 0x00FF;

typedef uint8_t                     BYTE;
typedef uint16_t                    WORD;

typedef uint64_t                    QWORD;
typedef uint32_t                    DWORD;

typedef struct {
    BYTE sFileName[13];
    BYTE bAttributes;
    WORD ff_time;
    WORD ff_date;
    QWORD dwFileSize;
} FFBLK;

typedef enum{
    FAT12,
    FAT16,
    FAT32,
    EXFAT,
    UNDEFINED
} FATTYPE;

typedef struct {
    BOOL enableAttr;            // Enable change attribute
    uint16_t attributes;
    
    BOOL enableCDate;           // Enable change creation date and time
    uint16_t creationDate;
    uint16_t creationTime;
    uint8_t creationTimeCS;     // exFAT only
    
    BOOL enableMDate;           // Enable change modification date and time
    uint16_t modificationDate;
    uint16_t modificationTime;
    uint8_t modificationTimeCS; // exFAT only
    
    BOOL enableADate;           // Enable change access date and time
    uint16_t accessDate;
    uint16_t accessTime;        // exFAT only
    
} FILE_ATTRIBUTE;

typedef enum {
  METHOD_NOT_IMPLEMENTED
} iXpandSDKErrorCode;

typedef NS_ENUM(NSInteger, iXpandSupportedDeviceType)
{
    iXpandFlashDrive_v1,
    iXpandFlashDrive_v2,
    iXpandFlashDrive_v3,
    iXpandFlashDrive_v6,            
    iXpandFlashDrive_v7,
    iXpandFlashDriveUnsupported
};

/**
 Accessory Callbacks enumeration.
 Possible accessory states are listed below.
 */

typedef enum : NSUInteger {
    ACCESSORY_FREE = 0,
    ACCESSORY_WAIT,
    ACCESSORY_BUSY,
    APP_IN_BACKGROUND
} AccessoryCallbacks;

/**
 Possible aplication states are listed below.
 */
typedef enum : NSUInteger {
    NEW = 0,
    PENDING,
    USING_ACCESSORY,
    WAIT,
    BUSY,
    INACTIVE,
    INVALID
} ApplicationState;

// Shortened form of a callback block used in API method below
typedef void(^AccessoryCallback)(AccessoryCallbacks accessoryStatus);
