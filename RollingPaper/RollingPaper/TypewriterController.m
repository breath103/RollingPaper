//
//  TypewriterViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "TypewriterController.h"
#import "macro.h"
#import "UELib/UEImageLibrary.h"
#import "UELib/UEUI.h"


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
    
    
    
    NSArray* fontArray = [self fontArray];
    NSArray* fontNameArray = [self fontNameArray];
    int index = 0;
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
        NSLog(@"%@\n%@",button,button.titleLabel);
        [self.fontPalette addSubview:button];
        
        [button addTarget:self
                   action:@selector(onTouchFontText:)
         forControlEvents:UIControlEventTouchUpInside];
        
        index ++;
    }
}
-(IBAction) onTouchFontText:(UIButton*)sender{
    self.textView.font = sender.titleLabel.font;
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
   // NSLog(@"%@",self.doneButton);
    
    
    [self.fontPalette fadeOut:0.3f];
    [self.colorPalette fadeOut:0.3f];
    
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
- (IBAction)onTouchEndType:(id)sender {
    UIImage* image = [UEImageLibrary imageFromView:self.textView];
    [self.delegate typewriterController : self
                           endEditImage : image];
}

- (IBAction)onTouchDone:(id)sender {
    if(self.textView.isFirstResponder){
        //현재 편집중이였던경우
        [self.textView resignFirstResponder];
    }
    else{
        [self onTouchEndType:NULL];
    }
}
- (IBAction)onTouchFontButton:(id)sender {
    if([self.fontPalette  fadeToggle:0.3f]){
        //보여지는 경우
        [self.colorPalette fadeOut:0.3f];
    }
}

- (IBAction)onTouchColor:(id)sender {
    if([self.colorPalette fadeToggle:0.3f]){
        //보여지는 경우
        [self.fontPalette fadeOut:0.3f];
    }
}

-(void) colorPalette:(ColorPalette *)palette
         selectColor:(UIColor *)color{
    self.textView.textColor = color;
}
@end
