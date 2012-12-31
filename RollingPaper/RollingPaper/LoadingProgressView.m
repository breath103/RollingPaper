//
//  LoadingProgressView.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "LoadingProgressView.h"

@implementation LoadingProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
 - (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 5.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGFloat dashArray[] = {2,2,2,2};
    CGContextSetLineDash(context, 3, dashArray, 4);
   // CGContextFillRect(context, rect);
    CGContextStrokeRect(context, rect);
    // Drawing code
}


@end
