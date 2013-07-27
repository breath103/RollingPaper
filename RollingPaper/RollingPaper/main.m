#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@implementation NSNull(CC)
- (NSInteger) length
{
    return 0;
}

@end

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}