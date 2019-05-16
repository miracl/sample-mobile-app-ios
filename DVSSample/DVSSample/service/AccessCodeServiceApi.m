#import "AccessCodeServiceApi.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@implementation AccessCodeServiceApi

- (void) verifySignature: (NSString *)verificationData documentData: (NSString *) docData withCallback:(void (^)(NSString* result, NSError* error)) callback {
    NSString *strBaseURL = [Config accessCodeServiceBaseUrl];
    NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/VerifySignature", strBaseURL]];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:theUrl resolvingAgainstBaseURL:NO];
    
    NSArray *queryItems = @[
                            [NSURLQueryItem queryItemWithName:@"verificationData" value:verificationData],
                            [NSURLQueryItem queryItemWithName:@"documentData" value:docData]
                            ];
    urlComponents.queryItems = queryItems;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];
    
    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"%@", error.localizedDescription);
            callback(nil, error);
        } else {
            NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(result, nil);
        }
    }] resume];
}

- (void) createDocumentHash:(NSString *)document withCallback:(void (^)(NSError* error, DocumentDvsInfo *info)) callback {
    
    NSString *strBaseURL = [Config accessCodeServiceBaseUrl];
    NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/CreateDocumentHash", strBaseURL]];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:theUrl resolvingAgainstBaseURL:NO];
    NSArray *queryItems = @[
                            [NSURLQueryItem queryItemWithName:@"document" value:document]
                            ];
    urlComponents.queryItems = queryItems;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];

    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            callback(error, nil);
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if(error) {
                callback(error, nil);
                return;
            }
            DocumentDvsInfo *info = [[DocumentDvsInfo alloc] init];
            info.timestamp = [[json valueForKey:@"timestamp"] longValue];
            info.authToken = [json valueForKey:@"authToken"];
            info.hashValue = [json valueForKey:@"hash"];
            callback(nil, info);
        }
    }] resume];
}

- (void) setAuthToken:(NSString *) authCode userID:(NSString *)userID withCallback:(void (^)(NSError* error)) callback  {
    NSString *strBaseURL = [Config accessCodeServiceBaseUrl];
    NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/authtoken",strBaseURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[authCode, userID] forKeys:@[@"code", @"userID"]];
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if(error) {
        callback(error);
        return;
    }
    request.HTTPBody = bodyData;
    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"%@", error.localizedDescription);
            callback(error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if([httpResponse statusCode] == 200) {
                callback(nil);
            } else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Could not set auth token" forKey:NSLocalizedDescriptionKey];
                NSError *apiError = [NSError errorWithDomain:@"AccessCodeError" code:200 userInfo:details];
                callback(apiError);
            }
        }
    }] resume];
}

- (void) obtainAccessCode:(void (^)(NSString *accessCode, NSError* error)) callback {
    NSString *strBaseURL = [Config accessCodeServiceBaseUrl];
    NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/authzurl",strBaseURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];
    request.HTTPMethod = @"POST";
        
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"%@", error.localizedDescription);
            callback(nil, error);
        } else {
            NSError *err;
            NSDictionary *config = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if(err != nil) {
                NSLog(@"%@", error.localizedDescription);
                callback(nil, error);
            } else {
                NSString *authorizeURL = config[@"authorizeURL"];
                if(authorizeURL.length > 0) {
                    NSString *accessCode = nil;
                    MpinStatus *status = [MPinMFA GetAccessCode:authorizeURL accessCode:&accessCode];
                    if(status.status == OK) {
                        callback(accessCode, error);
                    } else {
                        NSMutableDictionary* details = [NSMutableDictionary dictionary];
                        [details setValue:@"could not generate access code" forKey:NSLocalizedDescriptionKey];
                        NSError *apiError = [NSError errorWithDomain:@"AccessCodeError" code:200 userInfo:details];
                        callback(nil, apiError);
                    }
                } else {
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:@"empty authorizeURL returned" forKey:NSLocalizedDescriptionKey];
                    NSError *apiError = [NSError errorWithDomain:@"AccessCodeError" code:200 userInfo:details];
                    callback(nil, apiError);
                }
            }
        }
    }] resume];
}

@end
