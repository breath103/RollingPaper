#import <UIKit/UIKit.h>

@interface PaperBackgroundCell : UICollectionViewCell

@end


@protocol PaperBackgroundPickerDelegate;
@interface PaperBackgroundPicker : UIViewController<UICollectionViewDataSource,
                                                    UICollectionViewDelegate,
                                                    UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) id<PaperBackgroundPickerDelegate> delegate;
@property (nonatomic,strong) NSArray* backgroundList;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic,strong) NSString* selectedBackgroundName;
- (IBAction)onTouchDone:(id)sender;
- (IBAction)onTouchCancel:(id)sender;
-(id) initWithInitialBackgroundName:(NSString *)backgroundName
                           delegate:(id<PaperBackgroundPickerDelegate>)delegate;


@end

@protocol PaperBackgroundPickerDelegate <NSObject>
-(void) paperBackgroundPickerDidCancelPicking : (PaperBackgroundPicker*) picker;
-(void) paperBackgroundPicker : (PaperBackgroundPicker*) picker
            didPickBackground : (NSString*) backgroundName;
@end
