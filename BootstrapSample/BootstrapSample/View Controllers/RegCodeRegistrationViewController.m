#import "RegCodeRegistrationViewController.h"
#import "UsersTableViewController.h"
#import "RegisterUserViewController.h"
#import "UIAlertController+MPinHelper.h"

@interface RegCodeRegistrationViewController ()
@property(nonatomic,strong) id<IUser> selectedUser;

@property (weak, nonatomic) IBOutlet UIStackView *userDetailStackView;
@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *backendLabel;
@property (weak, nonatomic) IBOutlet UIButton *generateCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *registrationCodeLabel;

@end

@implementation RegCodeRegistrationViewController

#pragma mark - View controller lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

#pragma mark - Actions

- (IBAction)generateUserCode:(id)sender
{
    MpinStatus *authStatus = [MPinMFA StartAuthenticationRegCode:self.selectedUser];
    
    if (authStatus.status == OK) {
        __block UIAlertController *alertController = [UIAlertController enterPinAlertControllerForUserIdentity:[self.selectedUser getIdentity] andSubmitHandler:^(NSString *enteredPin) {
            if (enteredPin.length != 4) {
                [self showMessage:@"PIN must be 4 symbols"];
                return;
            }
            
            RegCode *registrationCode;
            MpinStatus *finishAuthenticationStatus = [MPinMFA FinishAuthenticationRegCode:self.selectedUser
                                                                                      pin:enteredPin
                                                                                     pin1:nil
                                                                                  regCode:&registrationCode];
            
            if (finishAuthenticationStatus.status == OK) {
                self.registrationCodeLabel.hidden = NO;
                self.registrationCodeLabel.text = [NSString stringWithFormat:@"Bootstrap Code is: %@",registrationCode.otp];
            } else {
                [self mPinOperationFailedWithStatus:finishAuthenticationStatus];
                self.registrationCodeLabel.hidden = YES;
            }
        }];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    } else {
        self.registrationCodeLabel.hidden = YES;
        [self mPinOperationFailedWithStatus:authStatus];
    }
}

-(IBAction)userSelectionUnwindSegue:(UIStoryboardSegue *)segue
{
    if([segue.identifier isEqualToString:@"selectRegisteredUserUnwindsegue"]){
        UsersTableViewController *usersTableViewController = segue.sourceViewController;
        self.selectedUser = usersTableViewController.selectedUser;
        [self updateUI];
    } else if ([segue.identifier isEqualToString:@"registerNewUserUnwindSegue"]){
        UINavigationController *navigationController = segue.sourceViewController;
        RegisterUserViewController *registerUserViewController = [navigationController.viewControllers firstObject];
        self.selectedUser = registerUserViewController.currentUser;
        [self updateUI];
    }
}

#pragma mark - Private methods

- (void)updateUI
{
    if(self.selectedUser != nil && [self.selectedUser getState] == REGISTERED) {
        self.userDetailStackView.hidden = NO;
        self.identityLabel.text = [NSString stringWithFormat:@"Identity: %@", [self.selectedUser getIdentity]] ;
        self.stateLabel.text = [NSString stringWithFormat:@"State: %@", [self userStateAsString:self.selectedUser]];
        self.customerIdLabel.text = [NSString stringWithFormat:@"CustomerId: %@", [self.selectedUser getCustomerId]];
        self.backendLabel.text = [NSString stringWithFormat:@"Backend: %@", [self.selectedUser getBackend]];
        self.generateCodeButton.hidden = NO;
    } else {
        self.userDetailStackView.hidden = YES;
        self.identityLabel.text = @"";
        self.stateLabel.text = @"";
        self.customerIdLabel.text = @"";
        self.backendLabel.text = @"";
        self.generateCodeButton.hidden = YES;
        self.registrationCodeLabel.hidden = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"selectUserSegue"]){
        UINavigationController *navigationController = segue.destinationViewController;
        UsersTableViewController *userTableViewController = [navigationController.viewControllers firstObject];
        userTableViewController.userSelectionMode = YES;
    }
}

-(NSString *)userStateAsString:(id<IUser>)user
{
    NSString *userStateAsString;
    switch ([user getState])
    {
        case INVALID:
            userStateAsString = @"INVALID";
            break;
        case REGISTERED:
            userStateAsString = @"REGISTERED";
            break;
        case BLOCKED:
            userStateAsString = @"BLOCKED";
            break;
        case STARTED_REGISTRATION:
            userStateAsString = @"STARTED_REGISTRATION";
            break;
        default:
            userStateAsString = @"INVALID";
            break;
    }
    return userStateAsString;
}

@end
