#import "SoundContent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SoundContentSpec)

describe(@"SoundContent", ^{
    __block SoundContent *model;
    
    beforeEach(^{
        model = [[SoundContent alloc]initWithDictionary:@{
                 @"x": @(100),
                 @"y": @(150),
                 @"height": @(4321),
                 @"id": @(1),
                 @"sound": @"http://us.123rf.com/400wm/400/400/aparagraph/aparagraph1103/aparagraph110300057/9109200-ripped-striped-background.jpg",
                 @"paper_id": @(4),
                 @"rotation": @(45),
                 @"user_id": @(5),
                 @"width": @(1234)
                 }];
    });
    
    describe(@"-initWithDictionary", ^{
        it(@"should be initialized",^{
            [model id] should equal(@(1));
            [model x] should equal(@(100));
            [model y] should equal(@(150));
            [model width] should equal(@(1234));
            [model height] should equal(@(4321));
            [model rotation] should equal(@(45));
            [model sound] should equal(@"http://us.123rf.com/400wm/400/400/aparagraph/aparagraph1103/aparagraph110300057/9109200-ripped-striped-background.jpg");
            [model paper_id] should equal(@(4));
            [model user_id] should equal(@(5));
        });
    });
    
    describe(@"+fromArray", ^{
        it(@"should return empty array for empty array",^{
            [SoundContent fromArray:@[]] should equal(@[]);
        });
        
        it(@"should return array from array",^{
            NSArray *result = [SoundContent fromArray:@[
                               @{@"id" : @(1)},@{@"id" : @(2)},@{@"id" : @(3)},@{@"id" : @(4)},
                               ]];
            [result count] should equal(4);
            for(SoundContent *content in result) {
                content should be_instance_of([SoundContent class]);
            }
            [result[0] id] should equal(@(1));
            [result[1] id] should equal(@(2));
            [result[2] id] should equal(@(3));
            [result[3] id] should equal(@(4));
        });
    });
    
    describe(@"-toDictionary", ^{
        it(@"should build dictionary",^{
            [model toDictionary] should equal(@{
                                              @"x": @(100),
                                              @"y": @(150),
                                              @"height": @(4321),
                                              @"id": @(1),
                                              @"sound": @"http://us.123rf.com/400wm/400/400/aparagraph/aparagraph1103/aparagraph110300057/9109200-ripped-striped-background.jpg",
                                              @"paper_id": @(4),
                                              @"rotation": @(45),
                                              @"user_id": @(5),
                                              @"width": @(1234)
                                              });
        });
    });
});

SPEC_END
