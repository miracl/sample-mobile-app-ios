#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (NSString*) companyId;
+ (NSURL *) authzURL;
+ (NSString *) mfaURL;

@end
