//
//  UEEntitiyView.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface UEEntitiyView : UIView
@property (nonatomic,strong) NSManagedObject* entity;
-(id) initWithEntity : (NSManagedObject*) aEntity
               frame : (CGRect) frame;
@end
