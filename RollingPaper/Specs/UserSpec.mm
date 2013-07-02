#import "User.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UserSpec)

describe(@"User", ^{
    __block User *model;

    beforeEach(^{
        model = [[User alloc]initWithDictionary:@{
            @"birthday": @"1993-09-05",
            @"created_at": @"2013-07-02T12:56:23Z",
            @"email": @"breath103@gmail.com",
            @"facebook_accesstoken": @"CAAEvpdZApPcYBAJKUjy6eOhBxFPrdsueNCwL7nDtYxCHbZBvwbm8SbuGknpZBKbqwkmfIZCCifLZCw2srEPB4vZB4NDHvtle7ffmRuBRTyJbjkS6TuKACHyb5N60C38gGn19U5u46mMGRo2FODroIjxXpNarX6orqGvnjoA38ntAZDZD",
            @"facebook_id": @"100002717246207",
            @"id": @(1),
            @"picture" : @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/572707_100002717246207_109162366_q.jpg",
            @"updated_at" : @"2013-07-02T12:56:23Z",
            @"username": @"Sanghyun  Lee"
        }];
    });
    
    describe(@"-init", ^{
        it(@"should initialized with dictionary",^{
            [model id] should equal(@(1));
            [model birthday] should equal(@"1993-09-05");
            [model email] should equal(@"breath103@gmail.com");
            [model facebook_accesstoken] should equal(@"CAAEvpdZApPcYBAJKUjy6eOhBxFPrdsueNCwL7nDtYxCHbZBvwbm8SbuGknpZBKbqwkmfIZCCifLZCw2srEPB4vZB4NDHvtle7ffmRuBRTyJbjkS6TuKACHyb5N60C38gGn19U5u46mMGRo2FODroIjxXpNarX6orqGvnjoA38ntAZDZD");
            [model facebook_id] should equal(@"100002717246207");
            [model picture] should equal(@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/572707_100002717246207_109162366_q.jpg");
            [model username] should equal(@"Sanghyun  Lee");
        });
    });
    
    describe(@"-toDictionary", ^{
        it(@"should return dictionary from user",^{
            [model toDictionary] should equal(@{
                                              @"birthday": @"1993-09-05",
                                              @"email": @"breath103@gmail.com",
                                              @"facebook_accesstoken": @"CAAEvpdZApPcYBAJKUjy6eOhBxFPrdsueNCwL7nDtYxCHbZBvwbm8SbuGknpZBKbqwkmfIZCCifLZCw2srEPB4vZB4NDHvtle7ffmRuBRTyJbjkS6TuKACHyb5N60C38gGn19U5u46mMGRo2FODroIjxXpNarX6orqGvnjoA38ntAZDZD",
                                              @"facebook_id": @"100002717246207",
                                              @"id": @(1),
                                              @"picture" : @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/572707_100002717246207_109162366_q.jpg",
                                              @"username": @"Sanghyun  Lee"
                                              });
        });
    });
});

SPEC_END
