#import "PaperTableViewCell.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"
#import "NSString+Vingle.h"
#import <QuartzCore/QuartzCore.h>

@implementation PaperTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *tapGestureRecoginaer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                            action:@selector(onBackgroundToched:)];
    [self addGestureRecognizer:tapGestureRecoginaer];
}

- (void)setPaper:(RollingPaper *)paper
{
    _paper = paper;
    [_backgroundImage setImageWithURL:[paper background]
    withFadeIn:0.3f
    success:^(BOOL isCached, UIImage *image) {
        _backgroundImage.image = nil;
        _backgroundImage.backgroundColor = [UIColor colorWithPatternImage:image];
//        UIImage* mask_image = [UIImage imageNamed:@"paper_cell_bg"];
//        CGSize size = _backgroundImage.frame.size;
//        CALayer *maskLayer = [CALayer layer];
//        maskLayer.frame = CGRectMake(0,0,size.width,size.height);
//        maskLayer.contents = (__bridge id)[mask_image CGImage];
//        self.layer.mask = maskLayer;
        [_backgroundImage setNeedsDisplay];
    } failure:^(NSError *error) {
    }];
    
    self.titleLabel.text = paper.title;
    [self updateDDayLabelInTime];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateDDayLabelInTime)
                                   userInfo:nil
                                    repeats:YES];

}
- (void) updateDDayLabelInTime{
    NSDate* currentDate = [NSDate date];
    NSDate* receiveDate = [[_paper receive_time] toDefaultDate];
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
- (IBAction)onBackgroundToched:(id)sender
{
    [_delegate paperTableViewCell:self touchBackground:self];
}
- (IBAction)onSettingTouched:(id)sender
{
    [_delegate paperTableViewCell:self settingTouched:sender];
}

@end
