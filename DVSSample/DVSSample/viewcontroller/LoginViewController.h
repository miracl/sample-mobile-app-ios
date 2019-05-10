#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

+ (LoginViewController *) instantiate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *userIdField;
@property (weak, nonatomic) IBOutlet UILabel *userStateField;
@property (weak, nonatomic) IBOutlet UILabel *userMpinBackendField;
@property (weak, nonatomic) IBOutlet UILabel *userCustomerIdField;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteUser;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginUser;



@end

