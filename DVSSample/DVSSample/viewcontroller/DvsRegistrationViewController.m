#import "DvsRegistrationViewController.h"
#import <MfaSdk/MPinMFA.h>
#import <MfaSdk/IUser.h>
#import "AppDelegate.h"
#import "SignMessageViewController.h"
#import "EnterPinViewController.h"
#import "Config.h"
#import "EnterPinViewController.h"

@interface DvsRegistrationViewController()

@property (nonatomic) BOOL registrationStarted;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UILabel *userIdentityField;
@property (weak, nonatomic) IBOutlet UIButton *btnRegisterDvs;

@end

@implementation DvsRegistrationViewController

+ (DvsRegistrationViewController*) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"DvsRegistrationViewController"];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = [AppDelegate delegate];
    self.userIdentityField.text = [self.currentUser getIdentity];
    [self.btnRegisterDvs addTarget:self action:@selector(registerDVSClicked) forControlEvents: UIControlEventTouchUpInside];
}

- (void) registerDVSClicked {
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

- (void) onPinEntered:(NSString *)pin {
    if(!self.registrationStarted) {
        [self startRegistrationDvs:pin];
    } else {
        [self finishRegistrationDvs:pin];
    }
}

-(void) startRegistrationDvs:(NSString *)pin {
    [self execAsync:^{
        MpinStatus *status = [MPinMFA StartRegistrationDVS:self.appDelegate.currentUser pin0:pin pin1:nil];
        if(status.status == OK) {
            self.registrationStarted = YES;
            [self execOnUiThread:^{
                __weak EnterPinViewController *enterPinController = [EnterPinViewController instantiate:@"Enter pin for signing"];
                enterPinController.pinCallback = ^(NSString *pin) {
                    [enterPinController dismissViewControllerAnimated:YES completion:^{
                        [self onPinEntered:pin];
                    }];
                };
                enterPinController.pinCancelCallback = ^{
                    [enterPinController dismissViewControllerAnimated: YES completion: nil];
                };
                [self presentViewController:enterPinController animated:YES completion:nil];
            }];
        } else {
            [self showMessage:status.errorMessage];
        }
    }];
}

-(void)finishRegistrationDvs:(NSString *)pin {
    [self execAsync:^{
        MpinStatus *status = [MPinMFA FinishRegistrationDVS:self.appDelegate.currentUser pinDVS:pin nfc:nil];
        if(status.status == OK) {
            [self execOnUiThread:^{
                NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [viewcontrollers removeLastObject];
                SignMessageViewController *controller = [SignMessageViewController instantiate];
                controller.currentUser = self.currentUser;
                [viewcontrollers addObject:controller];
                [self.navigationController setViewControllers:viewcontrollers animated:YES];
            }];
        } else {
            [self showMessage:status.errorMessage];
        }
    }];
}

@end
