#import "NSString+Vingle.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NSString_VingleSpec)

describe(@"NSString_Vingle", ^{
    beforeEach(^{

    });
    describe(@"toUnixTimestamps", ^{
        it(@"should return time stamps",^{
            [@"2013-07-12 16:53:19" toUnixTimestamp] should equal(1373647999);
        });
    });
    describe(@"toUTCDate", ^{
        it(@"should convert to date",^{
            [[@"2013-07-19 10:00:03" toUTCDate] description] should equal(@"2013-07-19 10:00:03 +0000");
        });
    });
});

SPEC_END
