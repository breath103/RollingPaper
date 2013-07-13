#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"

@implementation PaperSettingsViewController

- (id)initWithPaper:(RollingPaper *)paper
{
    self = [super init];
    if(self){
        _paper = paper;
    }
    return self;
}

- (void)setRecipient:(id<FBGraphUser>)recipient
{
    _recipient = recipient;
    [_recipientNameField setText:[recipient name]];
}

- (void)setBackground:(NSString *)background
{
    _background = background;
    [_backgroundImageView setImageWithURL:background
                               withFadeIn:0.1f];
}

- (void)setPaper:(RollingPaper *)paper
{
    _paper = paper;
    [_recipientNameField setText:[paper recipient_name]];
    [_titleField setText:[paper title]];
    [_noticeField setText:[paper notice]];
    
    [self setBackground:[paper background]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scrollView addSubview:_containerView];
    [_scrollView setContentSize:[_containerView frame].size];
    if (_paper)
        [self setPaper:_paper];
}

@end
