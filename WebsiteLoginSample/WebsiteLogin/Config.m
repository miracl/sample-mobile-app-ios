//
//  Config.m
//  WebsiteLogin
//
//  Created by Aleksandar Vlaev on 4/17/19.
//  Copyright © 2019 MIRACL. All rights reserved.
//

#import "Config.h"

@implementation Config
+(NSString*) clientId {
    return @"2eb980a7-38e7-4c33-8d64-f4668689a2e0";
}
+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", @"192.168.0.105"];
}
@end
