#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FlowithObject.h"

@interface Notice : FlowithObject
@property (nonatomic,retain) NSNumber* idx;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* text;
@property (nonatomic,retain) NSString* written_time;
@end
