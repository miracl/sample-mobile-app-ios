#import "BaseViewController.h"
#import <UIKit/UIKit.h>

@interface RegisterUserViewController : BaseViewController<UITextFieldDelegate>

+ (RegisterUserViewController*) instantiate;

@end
