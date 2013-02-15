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
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
-(IBAction)onTouchAddPaper:(id)sender;
-(IBAction)onTouchRefresh:(id)sender;
-(IBAction)onTouchProfile:(id)sender;
-(void) refreshPaperList;
//해당 아이디를 가진 페이퍼에 접근할 수 없는경우 false 접근 가능한경우 true
-(BOOL) showPaperWithIdx : (NSNumber*) paper_idx;

+(RollingPaperListController*) getInstance;
@end
