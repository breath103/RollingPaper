#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"
#import "FBFriendSearchPickerController.h"
#import "User.h"
#import "FlowithAgent.h"

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
        it(@"should hide create button", ^{
            [[controller exitButton] isHidden] should equal(YES);
        });
        
        describe(@"-facebookViewControllerDoneWasPressed", ^{
            context(@"with invitePicker",^{
                __block NSArray *friendList;
                beforeEach(^{
                    friendList = @[@"1",@"2",@"3"];
                    spy_on(controller);
                    [controller setInvitePicker:nice_fake_for([FBFriendSearchPickerController class])];
                    [controller invitePicker] stub_method(@selector(selection)).and_return(friendList);
                });
                subjectAction(^{
                    [controller facebookViewControllerDoneWasPressed:[controller invitePicker]];
                });
                it(@"should set friends list",^{
                    [controller friendList] should equal(friendList);
                });
            });
        });
        
        describe(@"showParticipantsButton", ^{
            it(@"should hide it",^{
                [[controller showParticipantsButton] isHidden] should equal(YES);
            });
        });
    });
    
    describe(@"init", ^{
        subjectAction(^{
            controller = [[PaperSettingsViewController alloc]initWithPaper:paper];
            controller.view = controller.view;
            navController = [[UINavigationController alloc]initWithRootViewController:controller];
            navController.view = navController.view;
        });
        
        it(@"should be initialized",^{
            controller should be_instance_of([PaperSettingsViewController class]);
            [controller paper] should equal(paper);
        });
        it(@"should init date pickers",^{
            [controller datePicker] should be_instance_of([UIDatePicker class]);
            [controller timePicker] should be_instance_of([UIDatePicker class]);
            
            [[controller receiveDateField] inputView] should equal([controller datePicker]);
            [[controller receiveTimeField] inputView] should equal([controller timePicker]);
        });
        it(@"should have participants view", ^{
            [controller participantsTableView] should be_instance_of([UITableView class]);
            [[controller participantsTableView] delegate] should equal(controller);
            [[controller participantsTableView] dataSource] should equal(controller);
        });
        
        describe(@"for edting paper", ^{
            context(@"for paper master",^{
                beforeEach(^{
                    [[FlowithAgent sharedAgent] setUserInfo:@{@"id": @(1234)}];
                });
                it(@"should be able to edit paper setting", ^{
                    [[controller recipientPickerButton] isEnabled] should equal(YES);
                    [[controller recipientNameField] isEnabled] should equal(NO);
                    
                    [[controller titleField] isEnabled] should equal(YES);
                    [[controller noticeField] isEnabled] should equal(YES);
                    [[controller receiveDateField] isEnabled] should equal(YES);
                    [[controller receiveTimeField] isEnabled] should equal(YES);
                    [[controller backgroundPickerButton] isEnabled] should equal(YES);
                    
                    [[controller exitButton] isHidden] should equal(NO);
                    [[controller exitButton] isEnabled] should equal(YES);
                });
            });
            context(@"for paper participants",^{
                beforeEach(^{
                    [[FlowithAgent sharedAgent] setUserInfo:@{@"id": @(1)}];
                });
                it(@"should not be able to edit paper setting", ^{
                    [[controller recipientPickerButton] isEnabled] should equal(NO);
                    [[controller recipientNameField] isEnabled] should equal(NO);
                    
                    [[controller titleField] isEnabled] should equal(NO);
                    [[controller noticeField] isEnabled] should equal(NO);
                    [[controller receiveDateField] isEnabled] should equal(NO);
                    [[controller receiveTimeField] isEnabled] should equal(NO);
                    [[controller backgroundPickerButton] isEnabled] should equal(NO);
                    
                    [[controller exitButton] isHidden] should equal(NO);
                    [[controller exitButton] isEnabled] should equal(YES);
                });
            });
        });

    });
    
    describe(@"scrollView", ^{
        xit(@"should place container",^{
            [[controller containerView] superview] should equal([controller scrollView]);
            NSStringFromCGSize([[controller scrollView] contentSize])
                should equal(NSStringFromCGSize([controller containerView].frame.size));
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
                [[[controller datePicker] date] description]
                        should equal(@"2013-08-06 18:23:37 +0000");

                [[controller receiveTimeField] text] should equal(@"03:23:37");
                [[[controller timePicker] date] description]
                        should equal(@"2013-08-06 18:23:37 +0000");
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
    
    describe(@"-onTouchCancel", ^{
        subjectAction(^{
            [controller onTouchBack:nil];
        });
        xit(@"should do nothing and pop", ^{
            [navController topViewController] should_not equal(controller);
        });
    });
    
    describe(@"-onTouchDone", ^{
        beforeEach(^{
            spy_on(paper);
        });
        subjectAction(^{
            [controller onTouchDone:nil];
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
        describe(@"size", ^{
            it(@"Should have default value",^{
                [paper width] should equal(@(1440));
                [paper height] should equal(@(960));
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
        
    describe(@"-onTouchQuit", ^{
        subjectAction(^{
            [controller onTouchQuit:nil];
        });
        
        context(@"for paper master",^{
            beforeEach(^{
                [[FlowithAgent sharedAgent] setUserInfo:@{@"id": @(1234)}];
                spy_on([User currentUser]);
            });
            it(@"should call quit room", ^{
                [User currentUser] should have_received(@selector(quitPaper:success:failure:));
            });
        });
        context(@"for paper participants",^{
            beforeEach(^{
                [[FlowithAgent sharedAgent] setUserInfo:@{@"id": @(5241)}];
                spy_on([User currentUser]);
            });
            it(@"should call quit room", ^{
                [User currentUser] should have_received(@selector(quitPaper:success:failure:));
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
    
    describe(@"-invitePicker", ^{
        __block FBFriendSearchPickerController *invitePicker;
        subjectAction(^{
            invitePicker = [controller invitePicker];
        });
        it(@"should return recipient Picker",^{
            invitePicker should be_instance_of([FBFriendSearchPickerController class]);
            [invitePicker delegate] should equal(controller);
            [invitePicker allowsMultipleSelection] should equal(YES);
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
    
    describe(@"-onTouchInviteFriend", ^{
        beforeEach(^{
            spy_on(controller);
        });
        subjectAction(^{
            [controller onTouchInviteFriend:nil];
        });
        xit(@"should show invitePicker",^{
            [controller presentedViewController] should equal([controller invitePicker]);
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
    
    describe(@"FBFriendPickerDelegate", ^{
        describe(@"-facebookViewControllerDoneWasPressed", ^{
            context(@"with recipientPicker",^{
                beforeEach(^{
                });
                subjectAction(^{
                    [controller facebookViewControllerDoneWasPressed:[controller recipientPicker]];
                });
                xit(@"should set recipient if selected",^{
                    [controller recipient] should equal([[controller recipientPicker] selection][0]);
                });
            });
            context(@"with invitePicker",^{
                beforeEach(^{
                    spy_on([User currentUser]);
                });
                subjectAction(^{
                    [controller facebookViewControllerDoneWasPressed:[controller invitePicker]];
                });
                xit(@"should invite them",^{
                    [User currentUser] should
                    have_received(@selector(inviteFriends:toPaper:success:failure:))
                        .with(@[]).with(paper);
                });
            });
        });
    });
});

SPEC_END
