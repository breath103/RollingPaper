//
//  LoadingProgressView.m
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 22..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import "LoadingProgressView.h"
#import "ccMacros.h"

/*
@implementation LoadingProgressView
@synthesize imageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_circle"]];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.frame = CGRectMake(0, 0, 70, 70);
        self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.imageView];
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationOptionRepeat
                         animations:^{
                             self.imageView.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(359));
                         } completion:^(BOOL finished) {
                            
                         }];
    }
    return self;
}
+(void) show{
    
}
+(void) hide{
    
}
@end
 */
