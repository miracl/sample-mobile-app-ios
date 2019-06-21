#import <Foundation/Foundation.h>
#import <MfaSdk/MPinMFA.h>

@interface DocumentDvsInfo : NSObject

@property (nonatomic) long timestamp;
@property (nonatomic, strong) NSString *hashValue;
@property (nonatomic, strong) NSString *authToken;

- (NSString*) serializeDocumentDvsInfo:(DocumentDvsInfo *) info;
- (NSString*) serializeSignature:(BridgeSignature*) signature;

@end
