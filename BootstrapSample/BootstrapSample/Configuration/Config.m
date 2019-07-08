#import "Config.h"

@implementation Config

+ (NSString*) companyId
{
    NSString *companyId = <# Replace with your company id #>;
    NSAssert(companyId, @"Company Id cannot be nil");
    return companyId;
}

+ (NSURL *)authzURL
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.scheme = <# Replace with your backend protocol scheme #>;
    urlComponents.host = <# Replace with your backend URL #>;
    urlComponents.port = @(<# Replace with your backend Port #>);
    urlComponents.path = @"/authzurl";
    
    NSURL *authzURL = urlComponents.URL;
    NSAssert(authzURL, @"authzURL cannot be nil");
    
    return authzURL;
}

+ (NSString *)mfaURL
{
    return @"https://api.mpin.io";
}


@end
