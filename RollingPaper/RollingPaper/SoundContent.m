#import "SoundContent.h"
#import "UECoreData.h"

@implementation SoundContent
- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    [super setAttributesWithDictionary:dictionary];
    _sound = dictionary[@"sound"];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dictionary[@"sound"] = _sound;
    return dictionary;
}
@end
