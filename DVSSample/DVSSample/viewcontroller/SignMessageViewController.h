#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@interface SignMessageViewController : BaseViewController <UITextFieldDelegate>

+ (SignMessageViewController*) instantiate;

@property (nonatomic, strong) id<IUser> currentUser;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btnSign;


@end
