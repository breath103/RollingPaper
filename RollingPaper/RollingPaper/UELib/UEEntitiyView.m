//
//  UEEntitiyView.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "UEEntitiyView.h"




@implementation UEEntitiyView
@synthesize entity;

-(id) initWithEntity : (NSManagedObject*) aEntity
               frame : (CGRect) frame{
    self = [self initWithFrame:frame];
    if(self){
        self.entity = aEntity;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
