#import <Foundation/Foundation.h>

@interface DocumentDvsInfo : NSObject

@property (nonatomic) long timestamp;
@property (nonatomic, strong) NSString *hash;
@property (nonatomic, strong) NSString *authToken;

@end
