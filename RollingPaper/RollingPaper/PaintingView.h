//
//  PaintingView.h
//  TransformTest
//
//  Created by 이상현 on 12. 12. 26..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define APP_SCALE ([[UIScreen mainScreen] scale])


typedef enum TOOL_TYPE{
    PENCIL,
    BALLPEN,
    NAMEPEN,
    CRAYON,
    LIGHTPEN,
    TOOL_COUNT
} TOOL_TYPE;

@interface PathInfo : UIBezierPath{
    
}
@property (nonatomic,strong) UIColor* lineColor;
@property (nonatomic,readwrite) CGFloat lineAlpha;
-(void) drawInContext : (CGContextRef) context;
-(CGRect) boundingBox;
@end


@interface PaintingView : UIView
{
    CGPoint lastPoint;
}
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic,readwrite) CGFloat lineWidth;
@property (nonatomic,readwrite) CGFloat lineAlpha;
@property (nonatomic,readwrite) CGLineCap lineCapStyle;
@property (nonatomic,readwrite) CGLineJoin lineJoinStyle;

@property (nonatomic,assign) CGContextRef drawingContext;
@property (nonatomic,assign) CGLayerRef drawingLayer;
@property (nonatomic,assign) CGRect currentDirtyRect;
@property (nonatomic,strong) PathInfo* currentDrawingPath;
@property (nonatomic,strong) NSMutableArray* pathArray;
@property (nonatomic,strong) NSMutableArray* removedPathArray;
@property (nonatomic,readwrite) TOOL_TYPE toolType;
-(CGRect) CGPaintedRect;
-(CGRect) UIPaintedRect;
-(UIImage*) toImage;
-(void) undo;
-(void) redo;
-(BOOL) isCanUndo;
-(BOOL) isCanRedo;
-(void) clearWithAnimation : (BOOL) b;
@end
