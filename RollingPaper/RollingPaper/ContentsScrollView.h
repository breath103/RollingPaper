//
//  ContentsScrollView.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 29..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentsScrollView : UIScrollView<UIScrollViewDelegate>
{
    
}
@property (nonatomic,strong) UIView* contentsContainer;
-(void) addContentView : (UIView*) contentView;

@end
