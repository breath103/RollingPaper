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
-(void) createDefaultColorButtons{
    [self createColorButtonsWithColors:[ColorPalette getDefaultColorArray]];
}
-(void) createColorButtonsWithColors : (NSMutableArray*) aColors{
    self.colors = aColors;
    int index = 0;
    CGSize colorSize = CGSizeMake(29.5, 29.5);
    CGRect scrollBounds = CGRectNull;
    for(UIColor* color in self.colors){
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame  = CGRectMake(0,0,colorSize.width,colorSize.height);
        button.center = CGPointMake(15 + index++ * (colorSize.width + 8) + self.offset.x,
                                    self.bounds.size.height/2.0f + self.offset.y);
        
        scrollBounds = CGRectUnion(scrollBounds, button.frame);
        
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
    self.scrollView.contentSize = scrollBounds.size;
}

-(void) onSelectColor : (UIButton*) sender{
    [self selectColor:sender.backgroundColor];
}
-(void) selectColor:(UIColor *)color{
    self.lastSelectedColor = color;
    if(self.delegate)//[self.delegate respondsToSelector:@selector(colorPalette:)])
    {
        [self.delegate colorPalette:self
                        selectColor:color];
    }
    else{
        //delegate가 잘못된경우
        NSLog(@"%@",color);
    }
}
+(NSMutableArray*) getDefaultColorArray
{
    NSMutableArray* colors = [NSMutableArray arrayWithObjects:
                              [UIColor whiteColor],
                              UIColorXRGB(0,0,0),
                              UIColorXRGB(255,30,0),
                              UIColorXRGB(246,207,40),
                              UIColorXRGB(94,116,62),
                              UIColorXRGB(58,81,96),
                              UIColorXRGB(98,77,149),
                              UIColorXRGB(255,0,102), nil];
    return colors;
}
@end
