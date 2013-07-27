#include <time.h>
#include <xlocale.h>
#import "NSString+Vingle.h"
#import "NSDate+TimeAgo.h"

@implementation NSString (Vingle)

- (NSString *)stringByAddingInteger:(NSInteger)aInteger {
    NSString *result = self;
    NSCharacterSet *characterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([self rangeOfCharacterFromSet:characterSet].location == NSNotFound) {
        NSInteger newValue = [self integerValue] + aInteger;
        if (newValue < 0) {
            newValue = 0;
        }
        result = [NSString stringWithFormat:@"%d", newValue];
    }
    return result;
}

- (NSString *)timeAgoInWordsFromTimestamp {
    struct tm sometime;
    const char *formatString = "%Y-%m-%d %H:%M:%S %z";
    (void) strptime_l([self UTF8String], formatString, &sometime, NULL);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)];
    return [date timeAgo];
}
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                            (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (NSDate *) toUTCDate
{
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setCalendar:[NSCalendar currentCalendar]];
    [inFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [inFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];// H:M:SZ"];
    return [inFormat dateFromString:self];
}
- (NSInteger) toUnixTimestamp
{
    return [[self toUTCDate] timeIntervalSince1970];
}
@end
