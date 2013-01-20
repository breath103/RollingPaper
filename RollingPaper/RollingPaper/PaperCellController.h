//
//  PaperCellController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 23..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RollingPaper.h"

@class PaperCellController;

@protocol PaperCellDelegate <NSObject>
-(void) PaperCellTouched : (PaperCellController*) paper;
-(void) paperCellSettingTouched : (PaperCellController*) paper;
@end

@interface PaperCellController : UIViewController
@property (strong,nonatomic) IBOutlet UILabel* ddayLabel;
@property (strong,nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorForNew;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak,nonatomic) id<PaperCellDelegate> delegate;
@property (strong,nonatomic) RollingPaper* entity;
@property (nonatomic,strong) NSTimer* ddayUpdatingTimer;
-(id) initWithEntity : (RollingPaper*) entity
            delegate : (id<PaperCellDelegate>) delegate;
- (IBAction)onSettingTouched:(id)sender;
-(void) refreshViewWithEntity;

@end
