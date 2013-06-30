#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Content : NSObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * rotation;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)fromArray:(NSArray *)array;

@end
