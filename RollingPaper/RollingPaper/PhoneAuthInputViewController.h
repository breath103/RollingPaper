//
//  PhoneAuthInpuViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 22..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneAuthInputViewController : UIViewController
@property (nonatomic,strong) NSString* phone;
@property (nonatomic,readonly) NSString* authCode ;
-(id) initWithPhone : (NSString*) phone
        andAuthCode : (NSString*) authCode;

@end
