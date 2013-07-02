#import <Foundation/Foundation.h>
#import "FlowithObject.h"

@interface User : FlowithObject
@property(nonatomic, strong) NSString *birthday;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *facebook_accesstoken;
@property(nonatomic, strong) NSString *facebook_id;
@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *picture;
@end

@interface User (Networking)
-(void) getParticipaitingPapers : (void (^)(NSArray *papers)) callback
                        failure : (void (^)(NSError *error)) failure;
@end
