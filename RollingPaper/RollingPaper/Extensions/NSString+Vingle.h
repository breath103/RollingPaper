#import <Foundation/Foundation.h>

@interface NSString (Vingle)
- (NSString *)stringByAddingInteger:(NSInteger)aInteger;
- (NSString *)timeAgoInWordsFromTimestamp;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
