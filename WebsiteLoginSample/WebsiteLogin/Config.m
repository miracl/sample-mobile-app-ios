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
    return <# Replace with company id #>;
}
+(NSArray*) trustedDomains {
    return @[@"miracl.net", @"mpin.io", @"<# Replace with private ip/domain #>"];
}
@end
