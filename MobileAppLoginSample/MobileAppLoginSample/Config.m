#import "Config.h"

@implementation Config

+(NSString*) companyId {
    return <# Replace with your company id #>;
}

+(NSString*) backendDomain {
    return <#Replace with backend ip/domain#>;
}

+(int) backendPort {
    return <#Replace with backend ip/domain port#>;
}

+(NSString*) httpScheme {
    return @"http";
}

+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", @"miracl.cloud", [Config backendDomain]];
}

+(NSString*) authBackend {
    return @"https://api.mpin.io";
}

+(NSString*) authCheckUrl {
    return [NSString stringWithFormat:@"%@://%@:%d/authtoken", [Config httpScheme], [Config backendDomain], [Config backendPort]];
}

+(NSString*) authzUrl {
    return [NSString stringWithFormat:@"%@://%@:%d/authzurl",
            [Config httpScheme], [Config backendDomain], [Config backendPort]];
}

@end
