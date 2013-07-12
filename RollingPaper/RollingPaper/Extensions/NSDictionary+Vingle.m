#import "NSDictionary+Vingle.h"
#import "NSString+Vingle.h"

@implementation NSDictionary (Vingle)

- (NSDictionary *)dictionaryByReplacingNullsWithStrings {
    
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id null = [NSNull null];
    const NSString *blank = @"";
    
    for(NSString *key in self) {
        const id object = [self objectForKey:key];
        if(object == null) {
            [replaced setObject:blank forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:replaced];
}


- (NSString *) parameterStringForGetMethod
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:[self count]];
    for (id key in [self allKeys])
    {
        id value = self[key];        
        [array addObject:[NSString stringWithFormat:@"%@=%@",
                          key,
                          [value urlEncodeUsingEncoding:NSASCIIStringEncoding]]];
    }
    return [array componentsJoinedByString:@"&"];
}
@end

