//
//  PaperBackgroundPicker.m
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 17..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

#import "PaperBackgroundPicker.h"
#import "FlowithAgent.h"
#import "UELib/UEUI.h"
#import <QuartzCore/QuartzCore.h>


@implementation PaperBackgroundCell
-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:
                                       CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.selectedBackgroundView.backgroundColor = [UIColor redColor];
    }
    return self;
}
@end



@interface PaperBackgroundPicker ()

@end

@implementation PaperBackgroundPicker
- (IBAction)onTouchDone:(id)sender {
    if(self.selectedBackgroundName)
        [self.delegate paperBackgroundPicker:self
                           didPickBackground:self.selectedBackgroundName];
    else
        [self.delegate paperBackgroundPickerDidCancelPicking:self];
}

- (IBAction)onTouchCancel:(id)sender {
    [self.delegate paperBackgroundPickerDidCancelPicking:self];
}
-(id) initWithInitialBackgroundName : (NSString*) backgroundName
                           Delegate : (id<PaperBackgroundPickerDelegate>)delegate{
    self = [self initWithDefaultNib];
    if(self){
        self.delegate               = delegate;
        self.selectedBackgroundName = backgroundName;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[PaperBackgroundCell class]
            forCellWithReuseIdentifier:@"BackgroundCell"];
    
    // Do any additional setup after loading the view from its nib.
    [[FlowithAgent sharedAgent] getBackgroundList:^(BOOL isCaschedResponse,
                                                    NSArray *backgroundList){
        self.backgroundList = backgroundList;
        [self.collectionView reloadData];
        
        //기본 값을 선택
        for(int i=0;i<self.backgroundList.count;i++){
            NSString* backgroundName = [self.backgroundList objectAtIndex:i];
            if([backgroundName compare: self.selectedBackgroundName] == NSOrderedSame){
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]
                                                  animated:TRUE
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            }
        }
    }failure:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"경고"
                                   message:@"서버로부터 종이 배경들을 받아오는대 실패했습니다"
                                  delegate:NULL
                         cancelButtonTitle:@"확인"
                         otherButtonTitles:NULL, nil] show];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UICollectionViewDataSource Implementation
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.backgroundList.count;
}
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"BackgroundCell"
                                                               forIndexPath:indexPath];
    if (!cell) {
        NSLog(@"NO CELL");
    }
    NSString* backgroundName = [self.backgroundList objectAtIndex:[indexPath indexAtPosition:1]];
    [[FlowithAgent sharedAgent] getBackground:backgroundName
    response:^(BOOL isCachedResponse, UIImage *image) {
        cell.backgroundColor = [UIColor colorWithPatternImage:image];
    }];
    
   return cell;
}
// 4
/*-	 (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedBackgroundName = [self.backgroundList objectAtIndex:[indexPath indexAtPosition:1]];
    NSLog(@"%@",self.selectedBackgroundName );
}
- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}
@end
