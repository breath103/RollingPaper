#import <UIKit/UIKit.h>
#import "ImageContent.h"
#import "RollingPaperContentViewProtocol.h"

@interface ImageContentView : UIView<RollingPaperContentViewProtocol>
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) ImageContent* entity;
-(id) initWithEntity : (ImageContent*) entity;
@end
