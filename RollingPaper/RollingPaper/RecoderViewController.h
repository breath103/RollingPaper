//
//  RecoderViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 14..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UESoundRecoder.h"

@class RecoderViewController;
@protocol RecoderViewControllerDelegate<NSObject>
-(void) RecoderViewController : (RecoderViewController*) recoder
        onEndRecodingWithFile : (NSString*) file;
@end

@interface RecoderViewController : UIViewController
@property (nonatomic,strong) UESoundRecoder* recoder;
@property (nonatomic,weak) id<RecoderViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *recodeButton;

-(id) initWithDelegate : (id<RecoderViewControllerDelegate>) aDelegate;
- (IBAction)onTouchButton:(id)sender;
@end
