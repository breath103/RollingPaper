#import "Invitation.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InvitationSpec)

describe(@"Invitation", ^{
    __block Invitation *model;
    beforeEach(^{
        model = [[Invitation alloc]initWithDictionary:@{
                 @"id": @(1),
                 @"sender_id": @(2),
                 @"paper_id": @(5),
                 @"friend_facebook_id": @"100003298833229",
                 @"receiver_name": @"Sean Moon",
                 @"receiver_picture": @"ugly picture",
                 @"created_at": @"2013-07-08T14:24:11Z",
                 @"updated_at": @"2013-07-08T14:24:11Z"
                 }];
    });
    
    describe(@"-initWithDictionary", ^{
        it(@"should be initialized",^{
            [model id] should equal(@(1));
            [model senderId] should equal(@(2));
            [model paperId] should equal(@(5));
            [model friendFacebookId] should equal(@"100003298833229");
            [model receiverName] should equal(@"Sean Moon");
            [model receiverPicture] should equal(@"ugly picture");
            [model createdAt] should equal(@"2013-07-08T14:24:11Z");
            [model updatedAt] should equal(@"2013-07-08T14:24:11Z");
        });
    });
});

SPEC_END
