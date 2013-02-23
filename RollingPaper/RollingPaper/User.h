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
@property(nonatomic,strong) NSNumber* idx;
@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* picture;
-(id) initWithDict : (NSDictionary*) dict;
+(NSArray*) userWithDictArray : (NSArray*) dictArray;
//-(void) getPicture : (void(^)(UIImage* image)) callback;

@end
