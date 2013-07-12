
#import "TypewriterController.h"
#import <QuartzCore/QuartzCore.h>


#define DEFAULT_DURATION (0.3f)


@interface TypewriterController ()

@end

int originalTextViewHeight;
int originalButtonTop;

@implementation TypewriterController
@synthesize delegate;
@synthesize textView;
@synthesize colorPalette;
-(id)initWithDelegate:(id<TypewriterControllerDelegate>)aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class)
                          bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}
- (NSArray*) fontNameArray
{
    NSArray* array = [[NSArray alloc] initWithObjects:
                      @"서울남산",
                      @"서울한강",
                      @"나눔고딕",
                      @"나눔명조",
                      @"나눔 손글씨 붓",
                      @"나눔 손글씨 펜",nil];
    return array;
}
- (NSArray*) fontArray{
    NSArray* array = [[NSArray alloc] initWithObjects:
                      [UIFont fontWithName:@"SeoulNamsanM"   size:14],
                      [UIFont fontWithName:@"SeoulHangangM"  size:14],
                      [UIFont fontWithName:@"NanumGothic"    size:14],
                      [UIFont fontWithName:@"NanumMyeongjo"  size:14],
                      [UIFont fontWithName:@"NanumBrush"     size:14],
                      [UIFont fontWithName:@"NanumPen"       size:14], nil];
    return array;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
    self.colorPalette.delegate = self;
    [self.colorPalette createDefaultColorButtons];
    
    originalTextViewHeight = self.textView.frame.size.height;
    originalButtonTop = 391;
    
    [self.fontPalette           hideToTransparent];
    [self.colorPaletteContainer hideToTransparent];
    [self.textAlignContainer    hideToTransparent];
    
    self.colorButton.layer.cornerRadius = self.colorButton.bounds.size.width / 2.0f;
    self.colorButton.layer.borderWidth  = 3.0f;
    self.colorButton.layer.borderColor  = [UIColor whiteColor].CGColor;
    
    NSArray* fontArray = [self fontArray];
    NSArray* fontNameArray = [self fontNameArray];
    int index = 0;
    UIButton* lastButton = NULL;
    for(UIFont* font in fontArray){
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(15,16 + index * 28, 70, 17);
        button.titleLabel.font = font;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment   = UIControlContentVerticalAlignmentTop;
        button.backgroundColor = [UIColor clearColor];
        [button setTitle : [fontNameArray objectAtIndex:index]
                forState : UIControlStateNormal];
        [button setTitleColor : [UIColor blackColor]
                     forState : UIControlStateNormal];
        [button setTitleColor : [UIColor whiteColor]
                      forState:UIControlStateHighlighted];
        [self.fontPalette addSubview:button];
        
        [button addTarget:self
                   action:@selector(onTouchFontText:)
         forControlEvents:UIControlEventTouchUpInside];
        
        index ++;
        
        
        lastButton = button;
    }
    [self onTouchFontText:lastButton];
    
    self.textView.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
}
-(IBAction) onTouchFontText:(UIButton*)sender{
    self.textView.font = sender.titleLabel.font;
    self.textView.font = [UIFont fontWithName:self.textView.font.fontName size:28];
}
- (void) viewWillAppear:(BOOL)animated{
    [self.textView becomeFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
-(void) textViewDidBeginEditing:(UITextView *)aTextView{
    isInEditing = TRUE;
   
    [self.fontPalette           fadeOut:DEFAULT_DURATION];
    [self.colorPaletteContainer fadeOut:DEFAULT_DURATION];
    [self.textAlignContainer    fadeOut:DEFAULT_DURATION];
    
    [UIView animateWithDuration:0.3f animations:^{
        UIViewSetY(self.doneButton,self.view.frame.size.height - KEYBOARD_HEIGHT - self.doneButton.frame.size.height);
        UIViewSetHeight(self.textView,self.view.frame.size.height - KEYBOARD_HEIGHT);
    } completion:^(BOOL finished) {
    
    }];
}
-(void) textViewDidEndEditing:(UITextView *)aTextView{
    isInEditing = FALSE;
    [UIView animateWithDuration:0.3 animations:^{
        UIViewSetY(self.doneButton,originalButtonTop);
        UIViewSetHeight(self.textView,originalTextViewHeight);
    } completion:^(BOOL finished) {
        
    }];
}
- (UIImage*) buildImage{
    UITextView* view = self.textView;
    
    UIColor* prevColor = self.view.backgroundColor;
    self.view.backgroundColor = [UIColor clearColor];
    
    view.contentInset = UIEdgeInsetsZero;
    view.contentOffset = CGPointZero;
    
    NSLog(@"%@",self.textView.text);
    
    
    CGSize totalTextRect = CGSizeZero;
    
    for(NSString* line in [self.textView.text componentsSeparatedByString:@"\n"])
    {
        CGSize textRect = [line sizeWithFont:self.textView.font
                           constrainedToSize:self.textView.frame.size
                               lineBreakMode:NSLineBreakByCharWrapping];
        totalTextRect.height += textRect.height;
        if(totalTextRect.width < textRect.width){
            totalTextRect.width = textRect.width;
        }
    }
    view.editable = FALSE;
    [view resignFirstResponder];
 //   totalTextRect.width += 20;
 //   totalTextRect.height += 20;
    UIViewSetSize(view, totalTextRect);
    
    UIGraphicsBeginImageContextWithOptions(totalTextRect,
                                           view.opaque,
                                           [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = prevColor;
    
    
    return img;
}
- (IBAction)onTouchEndType:(id)sender {
    [self.delegate typewriterController : self
                           endEditImage : [self buildImage]];
}

- (IBAction)onTouchAlignButton:(id)sender {
    if([self.textAlignContainer  fadeToggle:DEFAULT_DURATION]){
        //보여지는 경우
        [self.colorPaletteContainer fadeOut:DEFAULT_DURATION];
        [self.fontPalette fadeOut:DEFAULT_DURATION];
    }
}

- (IBAction)onTouchDone:(id)sender {
    [self onTouchEndType:NULL];
}
- (IBAction)onTouchFontButton:(id)sender {
    if([self.fontPalette  fadeToggle:DEFAULT_DURATION]){
        //보여지는 경우
        [self.colorPaletteContainer fadeOut:DEFAULT_DURATION];
        [self.textAlignContainer fadeOut:DEFAULT_DURATION];
    }
}

- (IBAction)onTouchColor:(id)sender {
    if([self.colorPaletteContainer fadeToggle:DEFAULT_DURATION]){
        //보여지는 경우
        [self.fontPalette fadeOut:DEFAULT_DURATION];
        [self.textAlignContainer fadeOut:DEFAULT_DURATION];
    }
}

- (IBAction)onTouchTextAlignOptionButtons:(UIButton*)sender {
    self.textView.textAlignment = (UITextAlignment)(sender.tag - 1000);
    NSLog(@"%@",sender);
    NSLog(@"%d",sender.tag - 1000);
    [self.textAlignButton setImage:[sender imageForState:UIControlStateNormal] forState:UIControlStateNormal];
}

- (IBAction)onTouchCancel:(id)sender {
    [self.delegate typewriterControllerDidCancelTyping:self];
}

-(void) colorPalette:(ColorPalette *)palette
         selectColor:(UIColor *)color{
    [UIView animateWithDuration:0.15f animations:^{
        self.colorButton.backgroundColor = color;
        self.textView.textColor = color;
    } completion:^(BOOL finished) {
        
    }];
}
@end
