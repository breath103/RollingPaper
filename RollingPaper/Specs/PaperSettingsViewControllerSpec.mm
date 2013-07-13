#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PaperSettingsViewControllerSpec)

describe(@"PaperSettingsViewController", ^{
    __block PaperSettingsViewController *controller;
    __block RollingPaper *paper;
    beforeEach(^{
        paper = [[RollingPaper alloc]initWithDictionary:@{
                     @"id" : @(4321),
                     @"creator_id" : @(1234),
                     @"title":@"paper title",
                     @"notice" : @"paper notice",
                     @"width":@(1440),
                     @"height":@(960),
                     @"created_at" : @"2013-07-05T21:10:15Z",
                     @"updated_at" : @"2013-07-05T21:13:25Z",
                     @"receive_time" : @"receive time",
                     @"background":@"background url",
                     @"friend_facebook_id":@"facebook id",
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
        controller = [[PaperSettingsViewController alloc]initWithPaper:paper];
        controller.view = controller.view;
    });
    
    it(@"should be initialized",^{
        controller should be_instance_of([PaperSettingsViewController class]);
        [controller paper] should equal(paper);
    });
    
    describe(@"scrollView", ^{
        it(@"should place container",^{
            [[controller containerView] superview] should equal([controller scrollView]);
            NSStringFromCGSize([[controller scrollView] contentSize]) should equal(NSStringFromCGSize([controller containerView].frame.size));
        });
    });

    
    describe(@"setRecipient", ^{
        __block id recipient;
        beforeEach(^{
            recipient = nice_fake_for(@protocol(FBGraphUser));
            recipient stub_method(@selector(name)).and_return(@"new name");
        });
        subjectAction(^{
            [controller setRecipient:recipient];
        });
        it(@"should set recievername field",^{
            [controller recipient] should equal(recipient);
            [[controller recipientNameField] text] should equal(@"new name");
        });
    });
    
    describe(@"-setBackground", ^{
        beforeEach(^{
            spy_on([controller backgroundImageView]);
        });
        subjectAction(^{
            [controller setBackground:@"new background"];
        });
        it(@"should update background",^{
            [controller background] should equal(@"new background");
            //[controller backgroundImageView] should have_received(@selector(setImageWithURL:withFadeIn:)).with(@"new background").and_with(0.1f);
        });
    });
    
    describe(@"-setPaper", ^{
        beforeEach(^{
            [controller setPaper:paper];
        });
        it(@"should update views",^{
            [[controller recipientNameField] text] should equal(@"Sean Moon");
            [[controller titleField] text] should equal(@"paper title");
            [[controller noticeField] text] should equal(@"paper notice");
            
            [controller background] should equal(@"background url");
        });
    });
});

SPEC_END
