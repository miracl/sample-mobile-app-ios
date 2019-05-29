#import "Config.h"

@implementation Config
+(NSString*) companyId {
    return <# Replace with your company id from the platform #>;
}
+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", <# Replace with backend ip/domain #>];
}
@end
