#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MfaSdk/MPinMFA.h>
#import <MfaSdk/IUser.h>

@interface SignMessageViewController : BaseViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<IUser> currentUser;
+ (SignMessageViewController*) instantiate;

@end
