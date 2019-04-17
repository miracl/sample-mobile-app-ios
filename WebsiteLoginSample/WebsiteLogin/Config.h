#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Config : NSObject

+(NSString*) companyId;
+(NSArray*) trustedDomains;
    
@end

NS_ASSUME_NONNULL_END
