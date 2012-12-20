//
//  TextContentView.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "TextContentView.h"
#import "macro.h"
#import "CGPointExtension.h"
@implementation TextContentView

@synthesize entity;
@synthesize textView;
-(UIFont*)fontWithString : (NSString*) fontString{
    NSArray* components = [fontString componentsSeparatedByString:@":"];
    NSString* fontName = [components objectAtIndex:0];
    NSString* fontSize = [components objectAtIndex:1];
    return [UIFont fontWithName : fontName
                           size : [fontSize floatValue]];
     
}
-(UIColor*) colorWithLong : (long) colorLong{
    int red   = (int)(colorLong % 0x1000000 / 0x10000);
    int green = (int)(colorLong % 0x10000 / 0x100);
    int blue  = (int)(colorLong % 0x100);
    return [UIColor colorWithRed : red/255.0f
                           green : green/255.0f
                            blue : blue/255.0f
                           alpha : 1.0f];
}
-(id) initWithEntity : (TextContent*) aEntity{
    self = [self initWithFrame:CGRectMake(0, 0, 1, 1)];
    if(self){
        self.autoresizesSubviews = TRUE;
        
        self.entity = aEntity; 
        self.textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.textView];
        
        self.contentMode = UIViewContentModeScaleToFill;
        [self updateViewWithEntity];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) updateViewWithEntity{
    self.center = ccp(self.entity.x.floatValue,self.entity.y.floatValue);

    self.textView.font = [self fontWithString:self.entity.font];
    self.textView.text = self.entity.text;
    self.textView.textColor = [self colorWithLong:self.entity.color.longValue];
    CGRect viewBounds = self.bounds;
    viewBounds.size = [self.textView.text sizeWithFont:self.textView.font];
    self.bounds = viewBounds;
    
    self.transform = CGAffineTransformMakeRotation(self.entity.rotation.floatValue);
}
-(void) updateEntityWithView{
    NSNumber* angle  = (NSNumber *)[self valueForKeyPath:@"layer.transform.rotation.z"];
    NSNumber* scale  = (NSNumber *)[self valueForKeyPath:@"layer.transform.scale.x"];
    
    CGSize size = self.bounds.size;
    size.width  *= scale.floatValue;
    size.height *= scale.floatValue; //스케일 값을 곱해 실제 보이는 크기로 만든다.
    
    self.entity.rotation = angle;
    self.entity.x        = FLOAT_TO_NSNUMBER(self.center.x);
    self.entity.y        = FLOAT_TO_NSNUMBER(self.center.y);
}

@end
