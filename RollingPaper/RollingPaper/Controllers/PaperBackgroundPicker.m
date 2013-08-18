#import "PaperBackgroundPicker.h"
#import "FlowithAgent.h"
#import <QuartzCore/QuartzCore.h>
#import "ccMacros.h"
#import "UIAlertViewBlockDelegate.h"
#import "UIImageView+Vingle.h"

@implementation PaperBackgroundCell
-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.selectedBackgroundView.backgroundColor = [UIColor redColor];
    }
    return self;
}
- (void) awakeFromNib
{
    [super awakeFromNib];
}
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
-(id) initWithInitialBackgroundName:(NSString *)backgroundName
                           delegate:(id<PaperBackgroundPickerDelegate>)delegate{
    self = [self init];
    if(self){
        self.delegate               = delegate;
        self.selectedBackgroundName = backgroundName;
    }
    return self;
}

- (void)refreshBackgrounds{
    [[FlowithAgent sharedAgent] getPath:@"papers/backgrounds.json"
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSArray* backgrounds) {
        _backgroundList = backgrounds;
        [_collectionView reloadData];
        //기본 값을 선택
        for(int i=0;i<_backgroundList.count;i++){
            NSString* backgroundName = _backgroundList[i];
            if ([backgroundName compare: _selectedBackgroundName] == NSOrderedSame) {
                [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]
                                              animated:TRUE
                                        scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertViewBlock alloc]initWithTitle:@"경고"
                                        message:@"서버로부터 종이 배경들을 받아오는대 실패했습니다"
                                  blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                      if(clickedButtonIndex == 1){
                                          [self refreshBackgrounds];
                                      }
                                  }
                              cancelButtonTitle:@"확인"
                              otherButtonTitles:@"재시도", nil] show];
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self collectionView] registerNib:[UINib nibWithNibName:@"PaperBackgroundViewCell" bundle:nil]
            forCellWithReuseIdentifier:@"BackgroundCell"];
    [[self collectionView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_pattern"]]];
    [self refreshBackgrounds];
}

#pragma UICollectionViewDataSource Implementation
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [_backgroundList count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PaperBackgroundCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BackgroundCell"
                                                                           forIndexPath:indexPath];
    [[cell paperImage] setImageWithURL:_backgroundList[indexPath.item]
                            withFadeIn:0.1f];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedBackgroundName = [self.backgroundList objectAtIndex:[indexPath item]];
}
- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark - UICollectionViewFlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(67, 67);
}
@end
