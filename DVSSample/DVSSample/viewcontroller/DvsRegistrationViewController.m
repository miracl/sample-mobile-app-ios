#import "DvsRegistrationViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>
#import "AppDelegate.h"
#import "SignMessageViewController.h"
#import "EnterPinViewController.h"
#import "Config.h"
#import "EnterPinViewController.h"

@interface DvsRegistrationViewController()
@property (nonatomic) BOOL registrationStarted;
@end

@implementation DvsRegistrationViewController
@synthesize registrationStarted = _registrationStarted;

+ (DvsRegistrationViewController*) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"DvsRegistrationViewController"];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.userIdentityField.text = [self.currentUser getIdentity];
    [self.btnRegisterDvs addTarget:self action:@selector(registerDVSClicked) forControlEvents: UIControlEventTouchUpInside];
}

- (void) registerDVSClicked {
    __weak EnterPinViewController *pinViewController = [EnterPinViewController instantiate];
    pinViewController.pinCallback = ^(NSString* pin) {
        [pinViewController dismissViewControllerAnimated:YES completion:^{
            [self onPinEntered:pin];
        }];
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
        MpinStatus *status = [MPinMFA StartRegistrationDVS:[AppDelegate delegate].currentUser pin0:pin pin1:nil];
        if(status.status == OK) {
            self.registrationStarted = YES;
            [self execOnUiThread:^{
                __weak EnterPinViewController *enterPinController = [EnterPinViewController instantiate];
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
        MpinStatus *status = [MPinMFA FinishRegistrationDVS:[AppDelegate delegate].currentUser pinDVS:pin nfc:nil];
        if(status.status == OK) {
            [self execOnUiThread:^{
                [self.navigationController popViewControllerAnimated:NO];
                SignMessageViewController *controller = [SignMessageViewController instantiate];
                controller.currentUser = self.currentUser;
                [self.navigationController pushViewController:controller animated:YES];
            }];
        } else {
            [self showMessage:status.errorMessage];
        }
    }];
}

@end
