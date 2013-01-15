//
//  ColorPalette.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 30..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "ColorPalette.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorPalette
@synthesize colors;
@synthesize scrollView;
- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self _initScrollViews];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self _initScrollViews];
    }
    return self;
}

-(void) _initScrollViews{
    if(!self.scrollView){
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:self.scrollView];
    }
}

-(void) createColorButtonsWithColors : (NSMutableArray*) aColors{
    self.colors = aColors;
    int index = 0;
    CGSize colorSize = CGSizeMake(29.5, 29.5);
    for(UIColor* color in self.colors){
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame  = CGRectMake(0,0,colorSize.width,colorSize.height);
        button.center = CGPointMake(15 + index++ * (colorSize.width + 10), self.bounds.size.height/2.0f);
        
        button.layer.cornerRadius = (colorSize.width + colorSize.height) / 2.0f / 2.0f;
        button.layer.borderWidth  = 3.0f;
        button.layer.borderColor  = [UIColor whiteColor].CGColor;
        button.backgroundColor = color;
        
        button.layer.shadowRadius = 1.0;
        button.layer.shadowOffset = CGSizeMake(1,3);
        button.layer.shadowOpacity = 0.5;
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shouldRasterize = YES;
        button.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [button setTranslatesAutoresizingMaskIntoConstraints:YES];
        [button addTarget:self
                   action:@selector(onSelectColor:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView  addSubview:button];
    }
}

-(void) onSelectColor : (id) sender{
    if([self.delegate respondsToSelector:@selector(colorPalette:)])
    {
        [self.delegate colorPalette:self
                        selectColor:[sender backgroundColor]];
    }
    else{
        //delegate가 잘못된경우
        NSLog(@"%@",[sender background]);
    }
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
