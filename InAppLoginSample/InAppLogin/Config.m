//
//  Config.m
//  InAppLogin
//
//  Created by Aleksandar Vlaev on 4/16/19.
//

#import "Config.h"

@implementation Config

+(NSString*) clientId {
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
    
+(NSString*) mpinSdkBackend {
    return @"https://api.mpin.io";
}

+(NSString*) authCheckUrl {
    return @"https://demo.trust.miracl.cloud/authtoken";
}
    
@end
