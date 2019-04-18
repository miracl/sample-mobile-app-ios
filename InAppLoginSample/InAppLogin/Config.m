#import "Config.h"

@implementation Config

+(NSString*) clientId {
    return @"";
}

+(NSString*) backendDomain {
    return  @"";
}
    
+(int) backendPort {
    return 123;
}

+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", @"miracl.cloud", [Config backendDomain]];
}
    
+(NSString*) mpinSdkBackend {
    return @"https://api.mpin.io";
}

+(NSString*) authCheckUrl {
    return @"https://demo.trust.miracl.cloud/authtoken";
}
    
@end
