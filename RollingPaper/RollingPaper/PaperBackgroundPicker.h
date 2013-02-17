//
//  PaperBackgroundPicker.h
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 17..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

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
-(id) initWithInitialBackgroundName : (NSString*) backgroundName
                           Delegate : (id<PaperBackgroundPickerDelegate>)delegate;
@end

@protocol PaperBackgroundPickerDelegate <NSObject>
-(void) paperBackgroundPickerDidCancelPicking : (PaperBackgroundPicker*) picker;
-(void) paperBackgroundPicker : (PaperBackgroundPicker*) picker
            didPickBackground : (NSString*) backgroundName;
@end
