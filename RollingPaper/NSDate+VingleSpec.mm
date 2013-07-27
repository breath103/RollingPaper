#import "NSDate+Vingle.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NSDate_VingleSpec)

fdescribe(@"NSDate_Vingle", ^{
    describe(@"UTCTimeToLocalTime", ^{
        it(@"should convert to localtime",^{
            [[[@"2013-07-18 16:00:03" toUTCDate] UTCTimeToLocalTime] description] should equal(@"2013-07-19 01:00:03 +0000");
        });
    });
    
    describe(@"LocalTimeToUTCTime", ^{
        it(@"should convert to utcTime",^{
            [[[@"2013-07-19 01:00:03" toUTCDate] LocalTimeToUTCTime] description] should equal(@"2013-07-18 16:00:03 +0000");
        });
    });
});

SPEC_END
