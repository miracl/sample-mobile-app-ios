#import "Config.h"

@implementation Config

+(NSString*) companyId {
    return <# Replace with your company id #>;
}

+(NSString*) backendDomain {
    return  <#Replace with private ip/domain#>;
}
    
+(int) backendPort {
    return <#Replace with private ip/domain port#>;
}

+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", @"miracl.cloud", [Config backendDomain]];
}
    
+(NSString*) authBackend {
    return @"https://api.mpin.io";
}

+(NSString*) authCheckUrl {
    return [NSString stringWithFormat:@"https://%@:%d/authtoken", [Config backendDomain], [Config backendPort]];
}

+(NSString*) authzUrl {
    return [NSString stringWithFormat:@"http://%@:%d/authzurl",
            [Config backendDomain], [Config backendPort]];
}
    
@end
