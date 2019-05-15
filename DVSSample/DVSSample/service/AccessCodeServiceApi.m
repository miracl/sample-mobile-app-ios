#import "AccessCodeServiceApi.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@implementation AccessCodeServiceApi

- (void) verifySignature: (NSString *)verificationData documentData: (NSString *) docData withCallback:(void (^)(NSString* result, NSError* error)) callback {
    NSString *strBaseURL = [Config accessCodeServiceBaseUrl];
    docData = [docData stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    verificationData = [verificationData stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/VerifySignature?verificationData=%@&documentData=%@", strBaseURL, verificationData, docData]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
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
    document = [document stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    NSString *strBaseURL = [Config accessCodeServiceBaseUrl];
    NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/CreateDocumentHash?document=%@", strBaseURL, document]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
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
    NSData *bodyData = [NSKeyedArchiver archivedDataWithRootObject:dict requiringSecureCoding:NO error:&error];
    request.HTTPBody = bodyData;
    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"%@", error.localizedDescription);
            callback(error);
        } else {
            callback(error);
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
