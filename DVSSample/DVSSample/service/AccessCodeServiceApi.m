#import "AccessCodeServiceApi.h"
#import <MfaSdk/MPinMFA.h>
#import <MfaSdk/IUser.h>

@implementation AccessCodeServiceApi

- (void) verifySignature: (NSString *)verificationData documentData: (NSString *) docData withCallback:(void (^)(NSString* result, NSError* error)) callback {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.path = @"/login/VerifySignature";
    urlComponents.scheme = [Config httpScheme];
    urlComponents.host = [Config accessCodeServiceBaseUrl];
    urlComponents.port = [Config accessCodeServicePort];
    
    NSArray *queryItems = @[
                            [NSURLQueryItem queryItemWithName:@"verificationData" value:verificationData],
                            [NSURLQueryItem queryItemWithName:@"documentData" value:docData]
                            ];
    urlComponents.queryItems = queryItems;
    
    NSURL *fullUrl = urlComponents.URL;
    if(fullUrl == nil || fullUrl.absoluteString.length == 0 ||
       ![self isSchemeValid:urlComponents.scheme]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid input parameters" forKey:NSLocalizedDescriptionKey];
        NSError *apiError = [NSError errorWithDomain:@"VerifySignature" code:200 userInfo:details];
        callback(nil, apiError);
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];
    
    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"%@", error.localizedDescription);
            callback(nil, error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if([httpResponse statusCode] != 200) {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"HTTP server error" forKey:NSLocalizedDescriptionKey];
                NSError *apiError = [NSError errorWithDomain:@"VerifySignature" code:200 userInfo:details];
                callback(nil, apiError);
                return;
            }
            NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(result, nil);
        }
    }] resume];
}

- (void) createDocumentHash:(NSString *)document withCallback:(void (^)(NSError* error, DocumentDvsInfo *info)) callback {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.path = @"/login/CreateDocumentHash";
    urlComponents.host = [Config accessCodeServiceBaseUrl];
    urlComponents.port = [Config accessCodeServicePort];
    NSArray *queryItems = @[
                            [NSURLQueryItem queryItemWithName:@"document" value:document]
                            ];
    urlComponents.queryItems = queryItems;
    urlComponents.scheme = [Config httpScheme];
    
    NSURL *fullUrl = urlComponents.URL;
    if(fullUrl == nil || fullUrl.absoluteString.length == 0 || ![self isSchemeValid:urlComponents.scheme]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid input parameters" forKey:NSLocalizedDescriptionKey];
        NSError *apiError = [NSError errorWithDomain:@"VerifySignature" code:200 userInfo:details];
        callback(apiError, nil);
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];

    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            callback(error, nil);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if([httpResponse statusCode] != 200) {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"HTTP server error" forKey:NSLocalizedDescriptionKey];
                NSError *apiError = [NSError errorWithDomain:@"CreateDocumentHash" code:200 userInfo:details];
                callback(apiError, nil);
                return;
            }
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

- (void) setAuthToken:(NSString *) authCode userID:(NSString *)userID
         withCallback:(void (^)(NSError* error)) callback  {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.path = @"/authtoken";
    urlComponents.host = [Config accessCodeServiceBaseUrl];
    urlComponents.port = [Config accessCodeServicePort];
    urlComponents.scheme = [Config httpScheme];
    
    NSURL *fullUrl = urlComponents.URL;
    if(fullUrl == nil || fullUrl.absoluteString.length == 0 || ![self isSchemeValid:urlComponents.scheme]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid input parameters" forKey:NSLocalizedDescriptionKey];
        NSError *apiError = [NSError errorWithDomain:@"VerifySignature" code:200 userInfo:details];
        callback(apiError);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
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
    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.path = @"/authzurl";
    urlComponents.host = [Config accessCodeServiceBaseUrl];
    urlComponents.port = [Config accessCodeServicePort];
    urlComponents.scheme = [Config httpScheme];
    
    NSURL *fullUrl = urlComponents.URL;
    if(fullUrl == nil || fullUrl.absoluteString.length == 0
       || ![self isSchemeValid:urlComponents.scheme]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid input parameters" forKey:NSLocalizedDescriptionKey];
        NSError *apiError = [NSError errorWithDomain:@"VerifySignature" code:200 userInfo:details];
        callback(nil, apiError);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
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
                NSLog(@"%@", err.localizedDescription);
                callback(nil, err);
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


- (BOOL) isSchemeValid:(NSString *) scheme {
    return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
}

@end
