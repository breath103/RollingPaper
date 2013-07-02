#import "FlowithObject.h"

@implementation FlowithObject
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        [self setAttributesWithDictionary:dictionary];
    }
    return self;
}

+ (NSArray *)fromArray:(NSArray *)array
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[array count]];
    for(NSDictionary* dictionary in array){
        [result addObject:[[[self class] alloc]initWithDictionary:dictionary]];
    }
    return result;
}
- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    
}
- (NSDictionary *)toDictionary
{
    return @{};
}

@end
