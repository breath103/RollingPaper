#import "RollingPaper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RollingPaperSpec)

describe(@"RollingPaper", ^{
    __block RollingPaper *model;

    beforeEach(^{
        model = [[RollingPaper alloc]initWithDictionary:@{
                 @"id" : @(4321),
                 @"creator_id" : @(1234),
                 @"title":@"paper title",
                 @"notice" : @"paper notice",
                 @"width":@(1000),
                 @"height":@(500),
                 @"receive_time" : @"receive time",
                 @"background":@"background url",
                 @"friend_facebook_id":@"facebook id",
                 }];
    });
    
    describe(@"-init", ^{
        it(@"should initialized with dictionary",^{
            [model id] should equal(@(4321));
            [model creatorId] should equal(@(1234));
            [model title] should equal(@"paper title");
            [model notice] should equal(@"paper notice");
            [model width] should equal(@(1000));
            [model height] should equal(@(500));
            [model background] should equal(@"background url");
            [model receive_time] should equal(@"receive time");
            [model friend_facebook_id] should equal(@"facebook id");
        });
    });
    
    
    describe(@"-toDictionary", ^{
        it(@"should be serialized include id",^{
            [model toDictionary] should equal(@{
                                              @"id" : @(4321),
                                              @"creator_id" : @(1234),
                                              @"title":@"paper title",
                                              @"notice" : @"paper notice",
                                              @"width":@(1000),
                                              @"height":@(500),
                                              @"receive_time" : @"receive time",
                                              @"background":@"background url",
                                              @"friend_facebook_id":@"facebook id",
                                              });
        });
        it(@"should be serialized include id",^{
            [model setId:nil];
            [model toDictionary] should equal(@{
                                              @"creator_id" : @(1234),
                                              @"title":@"paper title",
                                              @"notice" : @"paper notice",
                                              @"width":@(1000),
                                              @"height":@(500),
                                              @"receive_time" : @"receive time",
                                              @"background":@"background url",
                                              @"friend_facebook_id":@"facebook id",
                                              });
        });

    });
    
    describe(@"+fromArray", ^{
        it(@"should return empty array for empty array",^{
            [RollingPaper fromArray:@[]] should equal(@[]);
        });
        
        it(@"should return paper array for paper array",^{
            NSArray* papers = [RollingPaper fromArray:@[
                               @{@"id":@(1)},
                               @{@"id":@(2)},
                               @{@"id":@(3)},
                               @{@"id":@(4)},
                               ]];
            [papers count] should equal(4);
            [papers[0] id] should equal(@(1));
            [papers[1] id] should equal(@(2));
            [papers[2] id] should equal(@(3));
            [papers[3] id] should equal(@(4));
        });
    });
});

SPEC_END
