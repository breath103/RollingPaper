//
//  PaperParticipantsListController.h
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 17..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class RollingPaper;
@interface PaperParticipantsListController : UIViewController<UITableViewDelegate,UITableViewDataSource>

-(id) initWithPaper:(RollingPaper*) paper;
@property (nonatomic,strong) RollingPaper* paper;
@property (nonatomic,strong) NSMutableArray* users;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
