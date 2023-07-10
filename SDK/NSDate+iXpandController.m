//
//  NSDate+iXpandController.m
//  Everapp
//
//  Created by Artem on 9/21/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#if !(TARGET_OS_SIMULATOR) && !(TARGET_OS_MACCATALYST)

#import "NSDate+iXpandController.h"

#define SecondsFrom2000To2001 31622400
#define SecondsFrom1904To1970 2082844800
#define SecondsFrom1601To1970 11644473600
#define SecondsFrom1970ToLastDayOf1978 283910400

@implementation NSDate (iXpandController)

+ (NSDate *)iXpandDateWithYear:(int)year
                      month:(int)month
                        day:(int)day
                       hour:(int)hour
                     minute:(int)minute
                     second:(int)second
                   timeZone:(NSTimeZone *_Nullable)timezone{
    
    NSDateComponents *components= [NSDateComponents new];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    
    if(timezone) {
        [components setTimeZone:timezone];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateFromComponents:components];
}

+(NSDate *)iXpandDateWithTimeIntervalSince2000:(NSTimeInterval)interval
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:interval-SecondsFrom2000To2001];
}

+(NSDate *)iXpandDateWithTimeIntervalSince1904:(NSTimeInterval)interval
{
    return [NSDate dateWithTimeIntervalSince1970:interval-SecondsFrom1904To1970
            -[[NSTimeZone defaultTimeZone] secondsFromGMT]];
}

+(NSDate *)iXpandDateWithTimeIntervalSince1601:(NSTimeInterval)interval
{
    return [NSDate dateWithTimeIntervalSince1970:interval-SecondsFrom1601To1970];
}

+(NSDate *)iXpandDateWithMSDOSDate:(uint16_t)date time:(uint16_t)time
{
    return [self iXpandDateWithMSDOSDate:date time:time timeZone:nil];
}

+(NSDate *)iXpandDateWithMSDOSDate:(uint16_t)date time:(uint16_t)time timeZone:(NSTimeZone *)tz
{
    return [self iXpandDateWithMSDOSDateTime:((uint32_t)date<<16)|(uint32_t)time timeZone:tz];
}

+(NSDate *)iXpandDateWithMSDOSDateTime:(uint32_t)msdos
{
    return [self iXpandDateWithMSDOSDateTime:msdos timeZone:nil];
}

+(NSDate *)iXpandDateWithMSDOSDateTime:(uint32_t)msdos timeZone:(NSTimeZone *)tz
{
    int second=(msdos&31)*2;
    int minute=(msdos>>5)&63;
    int hour=(msdos>>11)&31;
    int day=(msdos>>16)&31;
    int month=(msdos>>21)&15;
    int year=1980+(msdos>>25);
    return [self iXpandDateWithYear:year month:month day:day hour:hour minute:minute second:second timeZone:tz];
}

+(NSDate *)iXpandDateWithWindowsFileTime:(uint64_t)filetime
{
    return [NSDate iXpandDateWithTimeIntervalSince1601:(double)filetime/10000000];
}

+(NSDate *)iXpandDateWithWindowsFileTimeLow:(uint32_t)low high:(uint32_t)high
{
    return [NSDate iXpandDateWithWindowsFileTime:((uint64_t)high<<32)|(uint64_t)low];
}

+(NSDate *)iXpandDateWithCPMDate:(uint16_t)date time:(uint16_t)time
{
    int second=(time&31)*2;
    int minute=(time>>5)&63;
    int hour=(time>>11)&31;
    
    double seconds=second+minute*60+hour*3600+date*86400;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds+SecondsFrom1970ToLastDayOf1978];
}

@end

#endif
