//
//  NSDate+iXpandController.h
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#if !(TARGET_OS_SIMULATOR) && !(TARGET_OS_MACCATALYST)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//from https://github.com/ashang/unar/blob/master/XADMaster/NSDateXAD.m

@interface NSDate (iXpandController)

+(NSDate *)iXpandDateWithYear:(int)year
                     month:(int)month
                       day:(int)day
                      hour:(int)hour
                    minute:(int)minute
                    second:(int)second
                  timeZone:(NSTimeZone *_Nullable)timezone;
+(NSDate *)iXpandDateWithTimeIntervalSince2000:(NSTimeInterval)interval;
+(NSDate *)iXpandDateWithTimeIntervalSince1904:(NSTimeInterval)interval;
+(NSDate *)iXpandDateWithTimeIntervalSince1601:(NSTimeInterval)interval;
+(NSDate *)iXpandDateWithMSDOSDate:(uint16_t)date time:(uint16_t)time;
+(NSDate *)iXpandDateWithMSDOSDate:(uint16_t)date time:(uint16_t)time timeZone:(NSTimeZone *)tz;
+(NSDate *)iXpandDateWithMSDOSDateTime:(uint32_t)msdos;
+(NSDate *)iXpandDateWithMSDOSDateTime:(uint32_t)msdos timeZone:(NSTimeZone *)tz;
+(NSDate *)iXpandDateWithWindowsFileTime:(uint64_t)filetime;
+(NSDate *)iXpandDateWithWindowsFileTimeLow:(uint32_t)low high:(uint32_t)high;
+(NSDate *)iXpandDateWithCPMDate:(uint16_t)date time:(uint16_t)time;

@end

NS_ASSUME_NONNULL_END

#endif
