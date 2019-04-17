//
//  Config.h
//  WebsiteLogin
//
//  Created by Aleksandar Vlaev on 4/17/19.
//  Copyright © 2019 MIRACL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Config : NSObject

+(NSString*) clientId;
+(NSArray*) trustedDomains;
    
@end

NS_ASSUME_NONNULL_END
