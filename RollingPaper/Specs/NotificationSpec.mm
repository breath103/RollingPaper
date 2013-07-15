#import "Notification.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NotificationSpec)

describe(@"Notification", ^{
    describe(@"-initWithDictionary", ^{
        __block Notification *model;
        subjectAction(^{
            model = [[Notification alloc]initWithDictionary:@{
                @"id": @(4),
                 @"notification_type": @"invitation_received",
                 @"picture": @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/572707_100002717246207_109162366_q.jpg",
                 @"recipient_id": @(2),
                 @"sender_id": @(1),
                 @"source_id": @(105),
                 @"text": @"invitation from Sanghyun Lee to sgdfaesfgsdgadgawefgasdfas",
            }];
        });
        it(@"should be initliazed from dictionary",^{
            [model id] should equal(@(4));
            [model notificationType] should equal(@"invitation_received");
            [model picture] should equal(@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/572707_100002717246207_109162366_q.jpg");
            [model senderId] should equal(@(1));
            [model sourceId] should equal(@(105));
            [model text] should equal(@"invitation from Sanghyun Lee to sgdfaesfgsdgadgawefgasdfas");
        });
    });
});

SPEC_END
