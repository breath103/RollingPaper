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
{
    @private
    NSMutableArray* paperCellControllers;
}
@property (weak, nonatomic) IBOutlet UIScrollView *paperScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
-(IBAction)onTouchAddPaper:(id)sender;

@end
