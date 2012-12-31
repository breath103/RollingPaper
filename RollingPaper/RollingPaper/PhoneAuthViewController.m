//
//  PhoneAuthViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 22..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PhoneAuthViewController.h"
#import "NetworkTemplate.h"
#import "SBJSON.h"

@interface PhoneAuthViewController ()

@end

@implementation PhoneAuthViewController
@synthesize phoneInput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchDontUsePhone:(id)sender {
}

- (IBAction)onTouchStartAuth:(id)sender {
    UIAlertView* confirmView = [[UIAlertView alloc]initWithTitle:@"전화번호가 맞습니까?"
                                                         message:self.phoneInput.text
                                                        delegate:self
                                               cancelButtonTitle:@"wrong"
                                               otherButtonTitles:@"yes", nil];
    [confirmView show];
}
-(void) alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0: //취소버튼 누른경우
        {
        }break;
        case 1: //확인버튼 누른경우
        {
            [self onPhoneNumberConfirmed];
        }break;
        default:
            break;
    }
}
-(void) onPhoneNumberConfirmed{
    ASIFormDataRequest* request = [NetworkTemplate requestForPhoneAuth:phoneInput.text];
    [request setCompletionBlock:^{
        NSDictionary* result = [[[SBJSON alloc]init] objectWithString:request.responseString];
        NSString* authCode = [result objectForKey:@"authCode"];
        NSLog(@"server received auth code : %@",authCode);
        
    }];
    [request setFailedBlock:^{
        NSLog(@"서버와의 통신 : requestForPhoneAuth 실패");
        
    }];
    [request startAsynchronous];
}
- (void)viewDidUnload {
    [self setPhoneInput:nil];
    [super viewDidUnload];
}
@end
