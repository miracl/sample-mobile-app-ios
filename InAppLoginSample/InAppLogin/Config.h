#import <Foundation/Foundation.h>

@interface Config : NSObject

+(NSString*) companyId;
+(NSArray*) trustedDomains;
+(NSString*) backendDomain;
+(int) backendPort;
+(NSString*) authBackend;
+(NSString*) authCheckUrl;
+(NSString*) authzUrl;

@end
