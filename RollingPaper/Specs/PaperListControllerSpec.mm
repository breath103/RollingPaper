//#import "PaperListController.h"
//
//using namespace Cedar::Matchers;
//using namespace Cedar::Doubles;
//
//SPEC_BEGIN(PaperListControllerSpec)
//
//describe(@"PaperListController", ^{
//    __block PaperListController *controller;
//
//    beforeEach(^{
//        controller = [[PaperListController alloc]init];
//    });
//
//    describe(@"initializing", ^{
//        it(@"should be initalized",^{
//            controller should be_instance_of([PaperListController class]);
//        });
//        it(@"should have tabs",^{
//            [controller participatingTabButton] should be_instance_of([UIButton class]);
//            [controller receivedTabButton] should be_instance_of([UIButton class]);
//            [controller sendedTabButton] should be_instance_of([UIButton class]);
//        });
//    });
//    
//    describe(@"tabs", ^{
//        describe(@"participatingTabButton", ^{
//            describe(@"when touched", ^{
//                subjectAction(^{
//                    [[controller participatingTabButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
//                });
//                it(@"should scroll the tab",^{
//                    NSStringFromCGPoint([[controller paperScrollView] contentOffset]) should equal(@"{0, 0}");
//                });
//            });
//        });
//        describe(@"receivedTabButton", ^{
//            describe(@"when touched", ^{
//                subjectAction(^{
//                    [[controller receivedTabButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
//                });
//                it(@"should scroll the tab",^{
//                    NSStringFromCGPoint([[controller paperScrollView] contentOffset]) should equal(@"{295, 0}");
//                });
//            });
//        });
//        describe(@"sendedTabButton", ^{
//            describe(@"when touched", ^{
//                subjectAction(^{
//                    [[controller sendedTabButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
//                });
//                it(@"should scroll the tab",^{
//                    NSStringFromCGPoint([[controller paperScrollView] contentOffset]) should equal(@"{590, 0}");
//                });
//            });
//        });
//    });
//});
//
//SPEC_END
