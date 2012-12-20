//
//  TextContentView.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextContent.h"
#import "RollingPaperContentViewProtocol.h"

@interface TextContentView : UIView<RollingPaperContentViewProtocol>
@property (nonatomic,strong) UILabel* textView;
@property (nonatomic,strong) TextContent* entity;
-(id) initWithEntity : (TextContent*) entity;
@end
