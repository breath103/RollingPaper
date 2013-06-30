#import "ImageContent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ImageContentSpec)

describe(@"ImageContent", ^{
    __block ImageContent *model;

    beforeEach(^{
        model = [[ImageContent alloc]initWithDictionary:@{
                 
                 }];
    });
});

SPEC_END
