#import <Foundation/Foundation.h>

@interface DocumentDvsInfo : NSObject

@property (nonatomic) long timestamp;
@property (nonatomic, strong) NSString *hashValue;
@property (nonatomic, strong) NSString *authToken;

@end
