#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (NSString*) companyId;

+ (NSString*) accessCodeServiceBaseUrl;

+ (NSNumber*) accessCodeServicePort;

+ (NSString*) authBackend;

+ (NSString*) httpScheme;

@end
