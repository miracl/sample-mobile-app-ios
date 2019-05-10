#import <Foundation/Foundation.h>
#import "Config.h"
#import "DocumentDvsInfo.h"

@interface AccessCodeServiceApi : NSObject

- (void) setAuthToken:(NSString *) authCode userID:(NSString *)userID withCallback:(void (^)(NSError* error)) callback;
- (void) obtainAccessCode:(void (^)(NSString *accessCode, NSError* error)) callback;
- (void) createDocumentHash:(NSString *)document withCallback:(void (^)(NSError* error, DocumentDvsInfo *info)) callback;
- (void) verifySignature: (NSString *)verificationData documentData: (NSString *) docData withCallback:(void (^)(NSString* result, NSError* error)) callback;

@end
