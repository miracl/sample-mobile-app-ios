#import "APIManager.h"
#import "Config.h"
#import <MfaSdk/MPinMFA.h>

@implementation APIManager

-(void) getAccessCodeWithCompletionHandler:(void (^)(NSString*,NSError*))completionHandler
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[Config authzURL]];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    NSURLSessionTask * task = [sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil){
            completionHandler(nil,error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&jsonError];
        if (jsonError != nil){
            completionHandler(nil,error);
            return;
        }
        
        
        NSURL *authorizeURL = [NSURL URLWithString:jsonResponse[@"authorizeURL"]];
        if (authorizeURL == nil){
            NSString *errorMessage = [NSString stringWithFormat:@"Error when parsing authorizeURL: %@", jsonResponse[@"authorizeURL"]];
            NSError *error = [NSError errorWithDomain:@"com.miracl.errors"
                                                 code:8841
                                             userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            completionHandler(nil,error);
            return;
        }
        
        NSString *accessCode;
        MpinStatus *getAccessCodeStatus = [MPinMFA GetAccessCode:authorizeURL.absoluteString
                                                      accessCode:&accessCode];
        if(accessCode != nil && ![accessCode isEqualToString:@""]){
            completionHandler(accessCode, nil);
        } else {
            NSString *accessCodeError = getAccessCodeStatus.errorMessage;
            NSString *errorMessage = [NSString stringWithFormat:@"Error when getting access code: %@", accessCodeError];
            NSError *error = [NSError errorWithDomain:@"com.miracl.errors"
                                                 code:8842
                                             userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
            completionHandler(nil,error);
        }
    }];
    [task resume];
}

@end
