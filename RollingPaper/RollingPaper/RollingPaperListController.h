//
//  RollingPaperListController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperCellController.h"
@interface RollingPaperListController : UIViewController<PaperCellDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *paperScrollView;
@property (strong,nonatomic) NSMutableArray* rollingPapers;
- (IBAction)onTouchAddPaper:(id)sender;

@end
