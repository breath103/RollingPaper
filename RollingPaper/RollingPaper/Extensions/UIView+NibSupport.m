#import "UIView+NibSupport.h"

@implementation UIView (NibSupport)
-(id) initWithNib{
    self = [self initWithNib:NSStringFromClass(self.class)];
    if(self){
        
    }
    return self;
}
-(id) initWithNib : (NSString*) nibName{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName
                                                        owner:self
                                                      options:nil];
    // assuming the view is the only top-level object in the nib file (besides File's Owner and First Responder)
    UIView *nibView = [nibObjects objectAtIndex:0];
    self = (id)nibView;
    if(self){
    
    }
    return self;
}
+(UIView*) viewWithNib : (NSString*) nibName{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName
                                                        owner:self
                                                      options:nil];
    // assuming the view is the only top-level object in the nib file (besides File's Owner and First Responder)
    return [nibObjects objectAtIndex:0];
}

@end
