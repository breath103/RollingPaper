//
//  PaintingView.m
//  TransformTest
//
//  Created by 이상현 on 12. 12. 26..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PaintingView.h"
#import "CGPointExtension.h"
#import <QuartzCore/QuartzCore.h>


/********************************************************/
/*
    CGPath 등에 넣어지는 모든 값들은 우선 UITouch에서 받아와서 넣어지기 때문에 스케일이 적용되지 않은 사이즈이다.
    그려지는 비트맵과 CGLayer가 스케일이 적용되어져 있기 때문에 CGPath를 렌더링할때는 그냥 렌더링 하면되지만,
    결론적으로 CGLayer와 CFBitmapRef 모두 실제 크기는 레티나 디스플레이의 픽셀사이즈가 된다. 
    따라서 후에 이를 이미지화 하여 UIImage로 뽑았을때, UIImage의 크기는 레티나디스플레이의 픽셀사이즈 임으로 2배다
*/
/*******************************************************/


#define DEFAULT_COLOR [UIColor blackColor]
#define DEFAULT_WIDTH 5.0f
#define DEFAULT_ALPHA 1.0f


@implementation PathInfo
@synthesize lineColor;
@synthesize lineAlpha;
-(void) drawInContext : (CGContextRef) context{
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetShouldAntialias(context, TRUE);
    CGContextSetStrokeColorWithColor(context,self.lineColor.CGColor);
    CGContextSetLineJoin(context, self.lineJoinStyle);
    CGContextSetLineCap (context, self.lineCapStyle);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetFlatness(context, 2.0f);
    CGContextSetAlpha(context, self.lineAlpha);
    CGContextAddPath (context, self.CGPath);
    CGContextStrokePath(context);
}
-(CGRect) boundingBox{
    CGRect dirtyRect = CGPathGetPathBoundingBox(self.CGPath);
    dirtyRect.origin.x -= self.lineWidth;
    dirtyRect.origin.y -= self.lineWidth;
    dirtyRect.size.width  += self.lineWidth * 2;
    dirtyRect.size.height += self.lineWidth * 2;
    return dirtyRect;
}
@end


@implementation PaintingView
@synthesize lineColor;
@synthesize lineWidth;
@synthesize lineAlpha;
@synthesize lineCapStyle;
@synthesize lineJoinStyle;

@synthesize drawingContext;
@synthesize drawingLayer;
@synthesize currentDirtyRect;
@synthesize currentDrawingPath;
@synthesize pathArray;
@synthesize removedPathArray;
@synthesize toolType = _toolType;
@synthesize delegate;
@synthesize enablePainting;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // BitmapContext 생성. 32bit color ARGB로 color system 지정
        drawingContext = CGBitmapContextCreate(NULL,
                                               self.bounds.size.width * APP_SCALE,
                                               self.bounds.size.height * APP_SCALE,
                                               8,
                                               4 * self.bounds.size.width * APP_SCALE,
                                               CGColorSpaceCreateDeviceRGB(),
                                               kCGImageAlphaPremultipliedLast);
        CGContextSetAllowsAntialiasing( drawingContext, true);
        CGContextSetShouldAntialias( drawingContext, true);
        CGContextScaleCTM(drawingContext, APP_SCALE, APP_SCALE);
        CGContextSetInterpolationQuality(drawingContext,kCGInterpolationHigh);
        
        //drawLayer를 생성하고 drawLayer의 context의 drawing property를 설정한다.
        drawingLayer = CGLayerCreateWithContext(drawingContext,
                                                self.bounds.size,
                                                NULL);
        
        CGContextRef layerContext = CGLayerGetContext(drawingLayer);
        
        CGContextSetAllowsAntialiasing(layerContext, true);
        CGContextSetShouldAntialias(layerContext,true);
        //CGContextScaleCTM(layerContext, APP_SCALE, APP_SCALE);
        CGContextSetInterpolationQuality(layerContext,kCGInterpolationHigh);
        
        self.opaque = FALSE;
        self.backgroundColor = [UIColor clearColor];
        self.multipleTouchEnabled = TRUE;
        pathArray = [NSMutableArray new];
        removedPathArray = [NSMutableArray new];
        
        self.toolType = CRAYON;
        
        
        self.enablePainting = TRUE;
    }
    return self;
}

-(void) setToolType:(TOOL_TYPE)toolType{
    _toolType = toolType;
 //   NSLog(@"---%d : %@",toolType,TOOL_TYPE_STRING[toolType]);
    switch (_toolType) {
        case PENCIL :{
            
        }break;
        case NAMEPEN :{
            
        }break; 
        case LIGHTPEN :{
            
        }break;
        case BALLPEN :{
            
        }break;
        case CRAYON :{
            self.lineWidth = 8.0f;
            self.lineAlpha = 0.8f;
            self.lineColor = [UIColor blueColor];
            self.lineCapStyle  = kCGLineCapButt;
            self.lineJoinStyle = kCGLineJoinMiter;
        }break;
        default:{
            
        }break;
    }
}

-(void) syncPaintInfo : (PathInfo*) pathInfo{
    pathInfo.lineAlpha = self.lineAlpha;
    pathInfo.lineColor = self.lineColor;
    pathInfo.lineWidth = self.lineWidth;
    pathInfo.lineJoinStyle = self.lineJoinStyle;
    pathInfo.lineCapStyle  = self.lineCapStyle;
}
-(void) handleTouchBeganForTool : (NSSet*) touches{
    switch (self.toolType) {
        case CRAYON : {
            //매직펜의 경우 시작지점과 끝점에 좀더 큰 점 하나를 찍어주면 된다.
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self];
            
            PathInfo* startDot = [[PathInfo alloc]init];
            [startDot moveToPoint:currentPoint];
            [startDot addLineToPoint:currentPoint];
            [self syncPaintInfo:startDot];
            startDot.lineJoinStyle = kCGLineJoinRound;
            startDot.lineCapStyle  = kCGLineCapRound;
            startDot.lineWidth = self.lineWidth * 1.5;
            
            [startDot drawInContext: drawingContext];
            
            [self.pathArray addObject:startDot];
        }break;
            
        default:
            break;
    }
}
-(void) handleTouchEndForTool : (NSSet*) touches{
    switch (self.toolType) {
        case CRAYON : {
            //매직펜의 경우 시작지점과 끝점에 좀더 큰 점 하나를 찍어주면 된다.
            UITouch *touch = [touches anyObject];
            CGContextRef ctx = CGLayerGetContext(drawingLayer);
            CGPoint currentPoint = [touch locationInView:self];
            
            CGContextSetFillColorWithColor(ctx, self.lineColor.CGColor);
            CGContextSetAlpha(ctx, self.lineAlpha);
            float pointWidth = self.lineWidth * 1.5;
            currentPoint.x -= pointWidth / 2.0f;
            currentPoint.y -= pointWidth / 2.0f;
            CGContextFillEllipseInRect(ctx, CGRectMake(currentPoint.x,currentPoint.y,pointWidth,pointWidth));
        }break;
    
            
        default:
            break;
    }
}
-(void) touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if(self.enablePainting){
        currentDrawingPath = [[PathInfo alloc]init];
        lastPoint = [((UITouch*)[touches anyObject]) locationInView:self];
        self.currentDirtyRect = CGRectNull;
        
        [self handleTouchBeganForTool : touches];
        
        [self.delegate paintingViewStartDrawing:self];
    }
}
-(CGPoint) controlPointFromStart : (CGPoint) s
                             end : (CGPoint) e{
    return ccpAdd(s, ccpMult(ccpSub(e, s),1.3f));
}
-(void) touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event{
    if(self.enablePainting){
        UITouch *touch = [touches anyObject];
        
        CGContextRef ctx = CGLayerGetContext(drawingLayer);
        
        CGPoint prevPoint    = [touch previousLocationInView:self];
        CGPoint currentPoint = [touch locationInView:self];
        
        CGPoint mid1 = ccpMidpoint(lastPoint, prevPoint);
        CGPoint mid2 = ccpMidpoint(prevPoint, currentPoint);
        
        [self.currentDrawingPath moveToPoint:mid1];
        [self.currentDrawingPath addQuadCurveToPoint:mid2 controlPoint:prevPoint];
        [self syncPaintInfo:self.currentDrawingPath];
        
        self.currentDirtyRect = [self.currentDrawingPath boundingBox];
        
        lastPoint = prevPoint;
        
        
        PathInfo* tempPath = [[PathInfo alloc]init];
        [tempPath moveToPoint:mid1];
        [tempPath addQuadCurveToPoint:mid2 controlPoint:prevPoint];
        [self syncPaintInfo:tempPath];
        
        [tempPath drawInContext:ctx];
        
        //[self.currentDrawingPath drawInContext:ctx];
        //   [currentDrawingPath drawInContext:ctx];
        //  }
        
        [self setNeedsDisplayInRect:self.currentDirtyRect];
    }
}
-(void) onPaintEnd : (NSSet*) touches
             Event : (UIEvent*) event{
    if(self.enablePainting){
        [self handleTouchEndForTool:touches];
        
        CGContextRef drawingLayerContext = CGLayerGetContext(drawingLayer);
        CGContextClearRect(drawingLayerContext, self.bounds);
        [self.currentDrawingPath drawInContext:drawingLayerContext];
        
        // drawContext에 bounds의 위치, 크기로 drawLayer의 context에 그려진 라인을 출력한다.
        CGContextSetAlpha(drawingContext, 1.0f);
        CGContextDrawLayerInRect(drawingContext, self.bounds, drawingLayer);
        // drawLayer의 context를 지우고 새로운 line을 그릴 준비를 한다.
        CGContextClearRect(drawingLayerContext, self.bounds);
        
        [self.pathArray addObject:self.currentDrawingPath];
        //새로 그림을 그린경우 기존의 REDO가능한 Path 들은 자연스럽게 삭제된다
        [self.removedPathArray removeAllObjects];
        
        [self setNeedsDisplay];
        
        [self.delegate paintingViewEndDrawing:self];
    }
}
-(void) touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event{
    [self onPaintEnd:touches
               Event:event];
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self onPaintEnd:touches
               Event:event];
}
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Application의 graphic context를 가져온다.
    CGContextRef graphicContext = UIGraphicsGetCurrentContext();
    
    // 이미 그려저서 버퍼에 저장된 데이터를 그린다.
    CGImageRef drawnLineImage = CGBitmapContextCreateImage(drawingContext);
    CGContextSetAlpha(graphicContext, 1.0f);
    CGContextClipToRect(graphicContext, self.bounds);
    CGContextDrawImage(graphicContext, self.bounds, drawnLineImage);
    CGImageRelease(drawnLineImage);
    
    // 현재 그려지고 있는 선을 그린다
    CGContextClipToRect(graphicContext, self.currentDirtyRect);
    CGContextSetAlpha(graphicContext, 1.0f);
    CGContextDrawLayerInRect(graphicContext, self.bounds, drawingLayer);
}
-(CGRect) CGPaintedRect{
    return UIBoundsToCGBounds([self UIPaintedRect]);
}
-(CGRect) UIPaintedRect{
    CGRect paintedRect = CGRectNull;
    for(PathInfo* path in self.pathArray){
        CGRect boundingBox = path.boundingBox;
        paintedRect = CGRectUnion(paintedRect, boundingBox);
    }
    return paintedRect;
}
-(UIImage*) toImage{
    UIImage* returnImage = NULL;
    CGRect paintedRect = [self CGPaintedRect];
    if(CGRectIsNull(paintedRect)){
    //    NSLog(@"그림이 안그려져 있는 상태 !!!!!");
        returnImage = NULL;
    }
    else{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,
                                               self.opaque,
                                               0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        returnImage = UIGraphicsGetImageFromCurrentImageContext();
        returnImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(returnImage.CGImage,paintedRect)];
        UIGraphicsEndImageContext();
   }
    return returnImage;
}
#pragma mark //이미지를 필요한만큼만 할당하도록 개선 필요
-(UIImageView*) imageViewFromPathInfo : (PathInfo*) pathInfo{
    CGRect pathBounds = UIBoundsToCGBounds([pathInfo boundingBox]);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,
                                           self.opaque,
                                           0.0);
    [pathInfo drawInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    img = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage,pathBounds)];
    UIGraphicsEndImageContext();

    UIImageView* imageView = [[UIImageView alloc] initWithImage:img];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.frame = pathInfo.boundingBox;
    return imageView;
}
-(void) redrawAllPathArray{
    CGContextClearRect(drawingContext, self.bounds);
    for(PathInfo* path in self.pathArray){
        [path drawInContext:drawingContext];
    }
    [self setNeedsDisplay];
}
-(BOOL) isCanUndo{
    return self.pathArray.count > 0;
}
-(BOOL) isCanRedo{
    return self.removedPathArray.count > 0;
}
-(void) undo{
    if([self isCanUndo])
    {
        PathInfo* target = [self.pathArray lastObject];
        UIImageView* bufferImageView = [self imageViewFromPathInfo:target];
        [self addSubview:bufferImageView];
        [UIView animateWithDuration:0.2f animations:^{
            bufferImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [bufferImageView removeFromSuperview];
        }];
        [self.removedPathArray addObject:target];
        [self.pathArray removeObject:target];
        
        [self redrawAllPathArray];
    }
    else{
        NSLog(@"Can't Undo");
    }
}

-(void) clearWithAnimation : (BOOL) b{
    if(b){
        CGImageRef drawnLineImage = CGBitmapContextCreateImage(drawingContext);
        UIImage* image = [UIImage imageWithCGImage:drawnLineImage scale:APP_SCALE
                                       orientation:UIImageOrientationDownMirrored];
       
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imageView.image = image;
        [self addSubview:imageView];
        [UIView animateWithDuration:0.2f animations:^{
            imageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
        }];
        
        
        [self.removedPathArray removeAllObjects];
        [self.pathArray removeAllObjects];
        
        [self redrawAllPathArray];
    }
    else{
        [self.removedPathArray removeAllObjects];
        [self.pathArray removeAllObjects];
        
        [self redrawAllPathArray];
    }
}
-(void) redo{
    if([self isCanRedo]){
        PathInfo* target = [self.removedPathArray lastObject];
        UIImageView* bufferImageView = [self imageViewFromPathInfo:target];
        [self addSubview:bufferImageView];
        bufferImageView.alpha = 0.0f;
    
        [UIView animateWithDuration:0.2f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            bufferImageView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [bufferImageView removeFromSuperview];
            
            [self.pathArray addObject:target];
            [self.removedPathArray removeObject:target];
            
            [self redrawAllPathArray];
        }];
    }
    else{
        NSLog(@"Can't Redo");
    }
}
-(void) dealloc{
    CGLayerRelease(drawingLayer);
    CGContextRelease(drawingContext);
}

@end
