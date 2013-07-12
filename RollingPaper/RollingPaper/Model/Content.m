#import "Content.h"
#import "RollingPaper.h"


@implementation Content

- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    _id       = dictionary[@"id"];
    _paper_id = dictionary[@"paper_id"];
    _user_id  = dictionary[@"user_id"];
    _width    = dictionary[@"width"];
    _height   = dictionary[@"height"];
    _x        = dictionary[@"x"];
    _y        = dictionary[@"y"];
    _rotation = dictionary[@"rotation"];
}
- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithDictionary:@{
                                       @"paper_id" : _paper_id,
                                       @"user_id" : _user_id,
                                       @"x" : _x,
                                       @"y" : _y,
                                       @"width" : _width,
                                       @"height" : _height,
                                       @"rotation": _rotation,}];
    if (_id) {
        dictionary[@"id"] = _id;
    }
    
    return dictionary;
}

@end

