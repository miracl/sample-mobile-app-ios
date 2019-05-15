#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@interface SignMessageViewController : BaseViewController <UITextFieldDelegate>

+ (SignMessageViewController*) instantiate;

@property (nonatomic, strong) id<IUser> currentUser;

@end
