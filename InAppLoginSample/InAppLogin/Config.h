#import <Foundation/Foundation.h>

@interface Config : NSObject

+(NSString*) clientId;
+(NSArray*) trustedDomains;
+(NSString*) backendDomain;
+(int) backendPort;
+(NSString*) mpinSdkBackend;
+(NSString*) authCheckUrl;

@end
