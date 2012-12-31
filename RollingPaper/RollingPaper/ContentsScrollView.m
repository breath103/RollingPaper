//
//  ContentsScrollView.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 29..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "ContentsScrollView.h"

@implementation ContentsScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) addContentView:(UIView *)contentView{
    [self.contentsContainer addSubview:contentView];
}
-(void) setContentSize:(CGSize)contentSize{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
