//
//  User.h
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 3..
//  Copyright (c) 2013년 reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property(nonatomic,strong) NSString* birthday;
@property(nonatomic,strong) NSString* email;
@property(nonatomic,strong) NSString* facebook_accesstoken;
@property(nonatomic,strong) NSString* facebook_id;
@property(nonatomic,strong) NSNumber* id;
@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* picture;
@property(nonatomic,strong) NSString* phone;
- (id)initWithDictionary : (NSDictionary*) dict;
- (NSDictionary*) toDictionary;
+ (NSArray*) fromArray:(NSArray *)array;
@end

@interface User (Networking)
-(void) getParticipaitingPapers : (void (^)(NSArray *papers)) callback
                        failure : (void (^)(NSError *error)) failure;
@end
