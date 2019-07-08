#import <UIKit/UIKit.h>
#import <MfaSdk/MPinMFA.h>

@interface UIAlertController (MPinHelper)

+(instancetype) infoAlertWithMessage:(NSString *)message;
+(instancetype) errorAlertForMPinStatus:(MpinStatus *)mpinStatus;
+(instancetype) enterPinAlertControllerForUserIdentity:(NSString *)userIdentity
                                      andSubmitHandler:(void (^)(NSString* enteredPin))submitHandler;

+(instancetype) confirmPinAlertControllerForUserIdentity:(NSString *)userIdentity
                                              enteredPin:(NSString *)firstPin
                                        andSubmitHandler:(void (^)(bool))submitHandler;
@end

