//
//  ColorPalette.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 30..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColorPalette;

@protocol ColorPaletteDelegate <NSObject>
-(void) colorPalette : (ColorPalette*) palette
         selectColor : (UIColor*) color;
@end

@interface ColorPalette : UIView;
@property (nonatomic,weak) id<ColorPaletteDelegate> delegate;
@property (nonatomic,strong) NSMutableArray* colors;
@property (nonatomic,strong) UIScrollView* scrollView;
-(void) createColorButtonsWithColors : (NSMutableArray*) colors;
@end
