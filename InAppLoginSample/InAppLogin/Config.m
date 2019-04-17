//
//  Config.m
//  InAppLogin
//
//  Created by Aleksandar Vlaev on 4/16/19.
//

#import "Config.h"

@implementation Config

+(NSString*) clientId {
    return @"2eb980a7-38e7-4c33-8d64-f4668689a2e0";
}

+(NSString*) backendDomain {
    return  <# Set the domain name/ip address of the machine where the backend sample is running #>;
}

+(NSArray*) trustedDomains {
    // TODO add placeholder text here
    return @[@"miracl.net", @"mpin.io", @"miracl.cloud", [Config backendDomain]];
}

+(int) backendPort {
    return <# Set the port number of the machine where the backend sample is running #>;
}
    
+(NSString*) mpinSdkBackend {
    return @"https://api.mpin.io";
}

+(NSString*) authCheckUrl {
    return @"https://demo.trust.miracl.cloud/authtoken";
}
    
@end
