#import "RollingPaper.h"
#import "User.h"

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
                    @"created_at" : @"2013-07-05T21:10:15Z",
                    @"updated_at" : @"2013-07-05T21:13:25Z",
                    @"receive_time" : @"receive time",
                    @"background":@"background url",
                    @"friend_facebook_id":@"facebook id",
                    @"thumbnail" : @"thumbnail url",
                    @"recipient_name" : @"Sean Moon",
                    @"participants":@[
                        @{@"id" : @(1),
                          @"username": @"Sanghyun Lee",
                          @"facebook_id": @"100002717246207"},
                        @{@"id": @(2),
                          @"username": @"Na Yeon Lee",
                          @"facebook_id": @"100001033134560"}
                    ],
                    @"invitations": @[
                        @{@"id": @(1)},
                        @{@"id": @(2)},
                    ]
                 }];
    });
    
    describe(@"-init", ^{
        it(@"should initialized with dictionary",^{
            [model id] should equal(@(4321));
            [model createdAt] should equal(@"2013-07-05T21:10:15Z");
            [model updatedAt] should equal(@"2013-07-05T21:13:25Z");
            [model creatorId] should equal(@(1234));
            [model title] should equal(@"paper title");
            [model notice] should equal(@"paper notice");
            [model width] should equal(@(1000));
            [model height] should equal(@(500));
            [model thumbnail] should equal(@"thumbnail url");
            [model background] should equal(@"background url");
            [model receive_time] should equal(@"receive time");
            [model friend_facebook_id] should equal(@"facebook id");
            [model recipient_name] should equal(@"Sean Moon");
            
            
            [[model participants] count] should equal(2);
            [[model participants][0] id] should equal(@(1));
            [[model participants][0] username] should equal(@"Sanghyun Lee");
            [[model participants][0] facebook_id] should equal(@"100002717246207");
            
            [[model participants][1] id] should equal(@(2));
            [[model participants][1] username] should equal(@"Na Yeon Lee");
            [[model participants][1] facebook_id] should equal(@"100001033134560");
            
            [[model invitations] count] should equal(2);
            [[model invitations][0] id] should equal(@(1));
            [[model invitations][1] id] should equal(@(2));
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
                                              @"recipient_name" : @"Sean Moon"
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
                                              @"recipient_name" : @"Sean Moon"
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
    
    describe(@"-recipientDictionary", ^{
        it(@"should build mock facebook user object with dictionary",^{
            [model recipientDictionary] should equal(@{
                                                     @"id" : @"facebook id",
                                                     @"name" : @"Sean Moon"
                                                     });
            [model setRecipient_name:nil];
            [model setFriend_facebook_id:nil];
            [model recipientDictionary] should equal(@{});
        });
    });
    describe(@"-setRecipient", ^{
        subjectAction(^{
            [model setRecipient:(id)@{
             @"name" : @"Sang Hyun",
             @"id" : @"new recipient id"
             }];
        });
        it(@"should set recipient",^{
            [model recipient_name] should equal(@"Sang Hyun");
            [model friend_facebook_id] should equal(@"new recipient id");
        });
    });
});

SPEC_END
