#import "UILabel+Vingle.h"
#import "UIView+VerticalLayout.h"

@interface UILabelSizeCache : NSObject

@property (nonatomic,strong) NSMutableDictionary* sizeCache;

@end

@implementation UILabelSizeCache

- (id)init
{
    self = [super init];
    if(self){
        _sizeCache = [[NSMutableDictionary alloc]init];
    }
    return self;
}
+ (UILabelSizeCache *)sharedInstance
{
    static UILabelSizeCache *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[UILabelSizeCache alloc] init];
    });
    return __sharedInstance;
}
- (void) setSize:(CGSize) size
          forKey:(NSString *)key
{
    [_sizeCache setObject:NSStringFromCGSize(size) forKey:key];
}
- (CGSize) sizeForKey:(NSString *)key
{
    NSString *sizeString = [_sizeCache objectForKey:key];
    if(sizeString){
        return CGSizeFromString(sizeString);
    } else {
        return CGSizeZero;
    }
}

@end



@implementation UILabel (Vingle)

- (void)sizeWidthToFitWithCacheKey:(NSString *)key
{
    CGSize size = [[UILabelSizeCache sharedInstance] sizeForKey:key];
    if(CGSizeEqualToSize(size, CGSizeZero)) {
        [self sizeWidthToFit];
        [[UILabelSizeCache sharedInstance] setSize:self.frame.size
                                            forKey:key];
    } else {
        [self setSize:size];
    }
}
- (void)sizeHeightToFitWithCacheKey:(NSString *)key
{
    CGSize size = [[UILabelSizeCache sharedInstance] sizeForKey:key];
    
    if(CGSizeEqualToSize(size, CGSizeZero)) {
        [self sizeHeightToFit];
        [[UILabelSizeCache sharedInstance] setSize:self.frame.size
                                            forKey:key];
    } else {
        [self setSize:size];
    }
}


@end
