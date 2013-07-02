#import <Foundation/Foundation.h>

@interface FlowithObject : NSObject
- (void)setAttributesWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray*) fromArray:(NSArray *)array;
- (NSDictionary*) toDictionary;
@end
