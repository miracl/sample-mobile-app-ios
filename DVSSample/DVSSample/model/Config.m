#import "Config.h"

@implementation Config

+ (NSString*) companyId {
    return <# Replace with your company id #>;
}

+ (NSString*) accessCodeServiceBaseUrl {
    return  <# Replace with backend ip/domain hostname #> ;
}

+ (NSNumber*) accessCodeServicePort {
    return [NSNumber numberWithInteger: <# Replace with backend ip/domain port number #>];
}

+ (NSString*) httpScheme {
    return <# Replace with http scheme value #>;
}

+ (NSString*) authBackend {
    return @"https://api.mpin.io";
}

@end
