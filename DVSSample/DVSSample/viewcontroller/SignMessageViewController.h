#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@interface SignMessageViewController : BaseViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<IUser> currentUser;
+ (SignMessageViewController*) instantiate;

@end
