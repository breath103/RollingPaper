#import <QuartzCore/QuartzCore.h>

#import "PaperCellController.h"
#import "FlowithAgent.h"
#import "UIImageView+Vingle.h"


@implementation PaperCellController
@synthesize entity;
@synthesize delegate;
@synthesize ddayLabel;
@synthesize titleLabel;
@synthesize ddayUpdatingTimer;

-(id) initWithEntity : (RollingPaper*) aEntity
            delegate : (id<PaperCellDelegate>) aDelegate{
    self = [self initWithNibName:@"PaperCellController" bundle:NULL];
    if(self) {
        self.entity   = aEntity;
        self.delegate = aDelegate;
    }
    return self;
}

- (IBAction)onSettingTouched:(id)sender {
    [self.delegate paperCellSettingTouched:self];
}

- (void) startUpdateDDayLabel{
    [self updateDDayLabelInTime];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateDDayLabelInTime)
                                   userInfo:nil
                                    repeats:YES];
}
- (void) updateDDayLabelInTime{
    NSDate* currentDate = [NSDate date];
    NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970:self.entity.receive_time.longLongValue];
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *timeStep = [sysCalendar components:unitFlags
                                                fromDate:currentDate
                                                  toDate:receiveDate
                                                 options:0];
    if(timeStep.day == 0)
        self.ddayLabel.text = [NSString stringWithFormat:@"D-%02d:%02d:%02d",timeStep.hour,timeStep.minute,timeStep.second];
    else if(timeStep.day > 0)
        self.ddayLabel.text = [NSString stringWithFormat:@"D-%d",abs(timeStep.day)];
    else
        self.ddayLabel.text = [NSString stringWithFormat:@"D+%d",abs(timeStep.day)];

    
    [self.ddayLabel setNeedsDisplay];
}
- (NSString*) ddayStringWithDate : (long long) timestamp {
    NSDate* currentDate = [NSDate date];
    NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    int     ddayCount   = (int)[receiveDate timeIntervalSinceDate:currentDate] / 60 / 60 / 24;
    
    NSString* ddayString;
    if(ddayCount == 0){
        [self updateDDayLabelInTime];
        if(self.ddayUpdatingTimer){
            [self.ddayUpdatingTimer invalidate];
            self.ddayUpdatingTimer = NULL;
        }
        self.ddayUpdatingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(updateDDayLabelInTime)
                                                                userInfo:nil
                                                                 repeats:YES];
    }
    else if(ddayCount > 0)
        ddayString = [NSString stringWithFormat:@"D-%d",abs(ddayCount)];
    else
        ddayString = [NSString stringWithFormat:@"D+%d",abs(ddayCount)];

    return ddayString;
}

- (void)showShadow
{
    self.view.layer.shadowRadius = 3.0;
    self.view.layer.shadowOffset = CGSizeMake(0,0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showShadow];
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [self refreshViewWithEntity];
    [_backgroundImage setImageWithURL:entity.background
    withFadeIn:0.3f
    success:^(BOOL isCached, UIImage *image) {
        _backgroundImage.image = NULL;//image;
        _backgroundImage.backgroundColor = [UIColor colorWithPatternImage:image];
        UIImage* mask_image = [UIImage imageNamed:@"paper_cell_bg"];
        CGSize size = _backgroundImage.frame.size;
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(0,0,size.width,size.height);
        maskLayer.contents = (__bridge id)[mask_image CGImage];
        self.view.layer.mask = maskLayer;
        [_backgroundImage setNeedsDisplay];
    } failure:^(NSError *error) {
    
    }];
    
    if(self.entity.is_new.boolValue){
        NSLog(@"%@ 는 New",self.entity);
        self.indicatorForNew.hidden = NO;
    }
    else{
        self.indicatorForNew.hidden = YES;
    }
}

-(void) refreshViewWithEntity
{
    [self startUpdateDDayLabel];
    self.titleLabel.text = self.entity.title;
}

-(void) onTap {
    [self.delegate PaperCellTouched:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
