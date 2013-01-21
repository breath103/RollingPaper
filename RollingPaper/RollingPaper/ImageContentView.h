//
//  ImageContentView.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageContent.h"
#import "RollingPaperContentViewProtocol.h"
@interface ImageContentView : UIView<RollingPaperContentViewProtocol>
@property (nonatomic,strong) UIImageView* imageView;
@property (strong,nonatomic) ImageContent* entity;
-(id) initWithEntity : (ImageContent*) entity;
-(UIImage*) image;
-(void) setImage : (UIImage*) image;
@end
