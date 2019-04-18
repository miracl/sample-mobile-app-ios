#import "Config.h"

@implementation Config
+(NSString*) clientId {
    return <# Replace with company id #>;
}
+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", @"<# Replace with private ip/domain #>"];
}
@end
