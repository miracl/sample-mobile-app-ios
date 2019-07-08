#import <Foundation/Foundation.h>

@interface APIManager : NSObject

-(void) getAccessCodeWithCompletionHandler:(void (^)(NSString *,NSError *))completionHandler;

@end
