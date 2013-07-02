#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Content.h"


@interface TextContent : Content
@property (nonatomic, strong) NSNumber * color;
@property (nonatomic, strong) NSString * font;
@property (nonatomic, strong) NSString * text;
@end
