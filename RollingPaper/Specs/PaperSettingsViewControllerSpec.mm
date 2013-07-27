#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"
#import "FBFriendSearchPickerController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PaperSettingsViewControllerSpec)

describe(@"PaperSettingsViewController", ^{
    __block UINavigationController *navController;
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
                     @"created_at" : @"2013-07-05 21:10:15",
                     @"updated_at" : @"2013-07-05 21:13:25",
                     @"receive_time" : @"2013-08-06 18:23:37",
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
        navController = [[UINavigationController alloc]initWithRootViewController:controller];
        navController.view = navController.view;
    });
    
    describe(@"for creating paper", ^{
        beforeEach(^{
            controller = [[PaperSettingsViewController alloc]init];
            controller.view = controller.view;
        });
        it(@"should create empty paper", ^{
            [controller paper] should be_instance_of([RollingPaper class]);
            [[controller paper] id] == nil should equal(YES);
        });
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

    describe(@"set/get ReceiveTime", ^{
        describe(@"setter", ^{
            subjectAction(^{
                [controller setReceiveTime:@"2013-08-06 18:23:37"];
            });
            it(@"should update receiveTime Fields",^{
                [controller receiveTime] should equal(@"2013-08-06 18:23:37 +0000");
                // set Time as a local time
                // in this case GMT to KST . +9hour
                [[controller receiveDateField] text] should equal(@"2013-08-07");
                [[controller receiveTimeField] text] should equal(@"03:23:37");
            });
        });
        describe(@"getter", ^{
            beforeEach(^{
                [[controller receiveDateField] text] should equal(@"2013-08-07");
                [[controller receiveTimeField] text] should equal(@"03:23:37");
            });
            it(@"should return receiveTime (covert KST to GMT",^{
                [controller receiveTime] should equal(@"2013-08-06 18:23:37 +0000");
            });
        });
    });
    
    describe(@"setRecipient", ^{
        __block id recipient;
        beforeEach(^{
            recipient = @{@"id" : @"frined facebook id",
                          @"name" : @"friend name"};
        });
        subjectAction(^{
            [controller setRecipient:recipient];
        });
        it(@"should set recievername field",^{
            [controller recipient] should equal(recipient);
            [[controller recipientNameField] text] should equal(@"friend name");
        });
    });
    
    describe(@"-onTouchSave", ^{
        beforeEach(^{
            spy_on(paper);
        });
        subjectAction(^{
            [controller onTouchSave:nil];
        });
        describe(@"title", ^{
            beforeEach(^{
                [[controller titleField] setText:@"new paper title"];
            });
            it(@"should set title",^{
                [paper title] should equal(@"new paper title");
            });
        });
        describe(@"notice", ^{
            beforeEach(^{
                [[controller noticeField] setText:@"new paper notice"];
            });
            it(@"should set notice",^{
                [paper notice] should equal(@"new paper notice");
            });
        });
        describe(@"background", ^{
            beforeEach(^{
                [controller setBackground:@"new paper background"];
            });
            it(@"should set background",^{
                [paper background] should equal(@"new paper background");
            });
        });
        describe(@"receiveTime", ^{
            beforeEach(^{
                [[controller receiveDateField] setText:@"2012-09-05"];
                [[controller receiveTimeField] setText:@"11:51:24"];
            });
            it(@"should set receive_time (convert GMT to UTC",^{
                [controller receiveTime] should equal(@"2012-09-05 02:51:24 +0000");
            });
        });
        describe(@"recipient", ^{
            beforeEach(^{
                [controller setRecipient:(id)@{@"name" : @"me", @"id" : @"fb id"}];
            });
            it(@"should set recipient",^{
                paper should have_received(@selector(setRecipient:)).with(@{@"name" : @"me", @"id" : @"fb id"});
            });
        });
        context(@"if paper value is valid",^{
            it(@"should save to server",^{
                paper should have_received(@selector(saveToServer:failure:));
            });
        });
        xcontext(@"if paper value is invalid",^{
            beforeEach(^{
                [[controller titleField] setText:nil];
            });
            it(@"should show alert",^{
                paper should_not have_received(@selector(saveToServer:failure:));
            });
        });
    });
    
    describe(@"-recipientPicker", ^{
        __block FBFriendSearchPickerController *recipientPicker;
        subjectAction(^{
            recipientPicker = [controller recipientPicker];
        });
        it(@"should return recipient Picker",^{
            recipientPicker should be_instance_of([FBFriendSearchPickerController class]);
            [recipientPicker delegate] should equal(controller);
        });
    });
    
    xdescribe(@"-onTouchPickRecipient", ^{
        beforeEach(^{
            spy_on(controller);
        });
        subjectAction(^{
            [controller onTouchPickRecipient:nil];
        });
        it(@"should show friendpicker",^{
            [navController presentedViewController] should be_instance_of([FBFriendSearchPickerController class]);
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
            [controller recipient] should equal([paper recipientDictionary]);
            [[controller recipientNameField] text] should equal(@"Sean Moon");

            [[controller titleField] text] should equal(@"paper title");
            [[controller noticeField] text] should equal(@"paper notice");
            
            [controller background] should equal(@"background url");
            [controller receiveTime] should equal(@"2013-08-06 18:23:37 +0000");
        });
    });
});

SPEC_END
