#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) NSString * accessCode;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceRegistered;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceStartedRegistration;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceInfoView;

@property (weak, nonatomic) IBOutlet UILabel *lblIdentity;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblBackend;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerId;

@property (nonatomic, weak) IBOutlet UIButton *btnLogin;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnConfirm;
@property (nonatomic, weak) IBOutlet UIButton *btnResendEmail;
@property (nonatomic, weak) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteUnconfirmed;

@property (nonatomic, weak) IBOutlet UITextField *txtAddUser;
@property (nonatomic, weak) IBOutlet UIView *viewAddId;
@property (nonatomic, weak) IBOutlet UIView *viewStartedRegistration;
@property (weak, nonatomic) IBOutlet UIView  *viewInfo;
@property (weak, nonatomic) IBOutlet UIView  *viewRegistered;

@end
