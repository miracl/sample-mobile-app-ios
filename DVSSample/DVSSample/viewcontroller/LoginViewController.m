#import "LoginViewController.h"
#import <MfaSdk/MPinMFA.h>
#import <MfaSdk/IUser.h>
#import "AppDelegate.h"
#import "RegisterUserViewController.h"
#import "AccessCodeServiceApi.h"
#import "SignMessageViewController.h"
#import "DvsRegistrationViewController.h"
#import "EnterPinViewController.h"

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *userIdField;
@property (weak, nonatomic) IBOutlet UILabel *userStateField;
@property (weak, nonatomic) IBOutlet UILabel *userMpinBackendField;
@property (weak, nonatomic) IBOutlet UILabel *userCustomerIdField;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteUser;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginUser;
@property (nonatomic, strong) id<IUser> currentUser;
@property (nonatomic, strong) AppDelegate* appDelegate;

@end

@implementation LoginViewController

+ (LoginViewController *) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"LoginViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    self.appDelegate = [AppDelegate delegate];
    AccessCodeServiceApi* api = [[AccessCodeServiceApi alloc] init];
    [api obtainAccessCode:^(NSString *accessCode, NSError *error) {
        self.appDelegate.accessCode = accessCode;
        if(error) {
            [self showMessage: error.localizedDescription];
        }
    }];
    
    [self.btnDeleteUser addTarget:self action:@selector(onDeleteClick) forControlEvents: UIControlEventTouchUpInside];
    [self.btnLoginUser addTarget:self action:@selector(onLoginClick) forControlEvents: UIControlEventTouchUpInside];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureSdkAndCurrentUser];
}

- (void) onPinEntered: (NSString *) pin {
    NSString *accessCode = self.appDelegate.accessCode;
    if(accessCode.length > 0 && self.currentUser != nil) {
        [self execAsync:^{
            MpinStatus *status = [MPinMFA StartAuthentication:self.currentUser accessCode:accessCode];
            if(status.status == OK) {
                NSString *authCode = nil;
                MpinStatus *authStatus = [MPinMFA FinishAuthentication:self.currentUser pin:pin pin1:nil accessCode:accessCode authzCode:&authCode];
                if(self.currentUser == nil || [self.currentUser getState] == BLOCKED) {
                    [self showMessage:@"Identity has been blocked because of too many wrong PIN entries. You will need to create it again."];
                    [self onDeleteClick];
                    return;
                }
                if(authStatus.status == OK && authCode != nil) {
                    [self validateLogin:authCode];
                } else {
                    [self showMessage:authStatus.errorMessage];
                }
            }
        }];
    }
}

-(void) onDeleteClick {
    if(self.currentUser != nil) {
        [self execAsync:^{
            [MPinMFA DeleteUser:self.currentUser];
            self.currentUser = nil;
            [self execOnUiThread:^{
                self.userContainerHeightConstraint.constant = 0;
                RegisterUserViewController* registerUserViewController = [RegisterUserViewController instantiate];
                [self.navigationController popToRootViewControllerAnimated:NO];
                [self.navigationController pushViewController:registerUserViewController animated:YES];
            }];
        }];
    }
}

-(void) onLoginClick {
    AccessCodeServiceApi *api = [[AccessCodeServiceApi alloc] init];
    [api obtainAccessCode:^(NSString *accessCode, NSError *error) {
        if(error) {
            [self showMessage:error.localizedDescription];
        } else {
            [self execOnUiThread:^{
                self.appDelegate.accessCode = accessCode;
                [self startLogin];
            }];
        }
    }];
}

-(void) startLogin {
    __weak EnterPinViewController *pinViewController = [EnterPinViewController instantiate:[self.currentUser getIdentity]];
    pinViewController.pinCallback = ^(NSString* pin) {
        [pinViewController dismissViewControllerAnimated:YES completion:^{
           [self onPinEntered:pin];
        }];
    };
    pinViewController.pinCancelCallback = ^{
        [pinViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:pinViewController animated:YES completion:nil];
}

-(void) validateLogin:(NSString *)authCode {
    AccessCodeServiceApi *api = [[AccessCodeServiceApi alloc] init];
    [api setAuthToken:authCode userID:[self.currentUser getIdentity] withCallback:^(NSError *error) {
        if(error) {
            NSLog(@"error %@", error.localizedDescription);
        } else {
            self.appDelegate.currentUser = self.currentUser;
            [self execOnUiThread:^{
                if([self.currentUser canSign]) {
                    SignMessageViewController *controller = [SignMessageViewController instantiate];
                    controller.currentUser = self.currentUser;
                    [self.navigationController popViewControllerAnimated:NO];
                    [self.navigationController pushViewController:controller animated:YES];
                } else {
                    DvsRegistrationViewController *controller = [DvsRegistrationViewController instantiate];
                    controller.currentUser = self.currentUser;
                    [self.navigationController popViewControllerAnimated:NO];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }];
        }
    }];
}

- (void) configureSdkAndCurrentUser {
    self.userContainerHeightConstraint.constant = 0;
    [self execAsync:^{
        MpinStatus *status = [MPinMFA SetBackend: [Config authBackend]];
        if(status.status == OK) {
            [self loadCurrentUserAndInit];
        } else {
            [self showMessage:@"The MPin SDK did not initialize properly. Check you backend and CID configuration"];
        }
    }];
}

- (void) loadCurrentUser {
    NSMutableArray *usersList = [MPinMFA listUsers];
    NSMutableArray *registeredUsersList = [NSMutableArray array];
    for(int i=0; i < usersList.count; i++) {
        id<IUser> user = (id<IUser>)[usersList objectAtIndex:i];
        if([user getState] == REGISTERED) {
            [registeredUsersList addObject:user];
        } else {
            [MPinMFA DeleteUser:user];
        }
    }
    NSString *backend = [Config authBackend];
    for(int i=0; i < registeredUsersList.count; i++) {
        id<IUser> user = (id<IUser>)[registeredUsersList objectAtIndex:i];
        NSString *userBackend = [user getBackend];
        NSString *httpsUserBackend = [NSString stringWithFormat:@"https://%@", userBackend];
        
        if([backend isEqualToString:userBackend] || [backend isEqualToString:httpsUserBackend]) {
            self.currentUser = user;
            break;
        }
    }
}

- (void) loadCurrentUserAndInit {
    [self loadCurrentUser];
    if(self.currentUser == nil) {
        [self execOnUiThread:^{
            RegisterUserViewController* registerUserViewController = [RegisterUserViewController instantiate];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self.navigationController pushViewController:registerUserViewController animated:YES];
        }];
    } else {
        [self execOnUiThread:^{
            self.userContainerHeightConstraint.constant = 200;
            [self showCurrentUserData];
        }];
    }
}

- (void) showCurrentUserData {
    self.userIdField.text = [self.currentUser getMPinId];
    
    NSString* stateStr = nil;
    switch ([self.currentUser getState]) {
        case INVALID:
            stateStr = @"INVALID";
            break;
        case STARTED_REGISTRATION:
            stateStr = @"STARTED_REGISTRATION";
            break;
        case ACTIVATED:
            stateStr = @"ACTIVATED";
            break;
        case REGISTERED:
            stateStr = @"REGISTERED";
            break;
        case BLOCKED:
            stateStr = @"BLOCKED";
            break;
        default:
            stateStr = @"UNKNOWN";
            break;
    }
    self.userStateField.text = stateStr;
    self.userMpinBackendField.text = [self.currentUser getBackend];
    self.userCustomerIdField.text = [self.currentUser getCustomerId];
}


@end
