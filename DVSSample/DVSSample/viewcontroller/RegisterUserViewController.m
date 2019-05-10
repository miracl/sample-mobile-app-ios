#import "RegisterUserViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>
#import "AppDelegate.h"
#import "AccessCodeServiceApi.h"
#import "LoginViewController.h"
#import "EnterPinViewController.h"

@interface RegisterUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) id<IUser> currentUser;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *resendEmailBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmRegButton;


@end

@implementation RegisterUserViewController

+ (RegisterUserViewController*) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"RegisterUserViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Registration";
    self.textField.delegate = self;
    [self.submitButton addTarget:self action:@selector(onSubmitClick) forControlEvents: UIControlEventTouchUpInside];
    [self.resendEmailBtn addTarget:self action:@selector(onResendClick) forControlEvents: UIControlEventTouchUpInside];
    [self.confirmRegButton addTarget:self action:@selector(onConfirmClick) forControlEvents: UIControlEventTouchUpInside];
    
    self.resendEmailBtn.hidden = YES;
    self.confirmRegButton.hidden = YES;
    [self disableControls];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self resetViews];
}

-(void)onConfirmClick {
    if(!self.currentUser) {
        return;
    }
    [self disableControls];
    [self execAsync:^{
        MpinStatus* status = [MPinMFA ConfirmRegistration:self.currentUser];
        [self execOnUiThread:^{
            [self enableControls];
            if(status.status == OK) {
                __weak EnterPinViewController *pinViewController = [EnterPinViewController instantiate:@""];
                pinViewController.pinCallback = ^(NSString* pin) {
                    [pinViewController dismissViewControllerAnimated:YES completion:^{
                        [self onPinEntered:pin];
                    }];
                };
                pinViewController.pinCancelCallback = ^{
                    [pinViewController dismissViewControllerAnimated:YES completion:nil];
                };
                [self presentViewController:pinViewController animated:YES completion:nil];
            } else {
                [self showMessage: status.errorMessage];
            }
        }];
    }];
}

- (void) onPinEntered:(NSString *)pin {
    if(!self.currentUser || pin.length == 0) {
        return;
    }
    [self execAsync:^{
        MpinStatus *status = [MPinMFA FinishRegistration:self.currentUser pin0:pin pin1:nil];
        if(status.status == OK) {
            [self execOnUiThread:^{
                LoginViewController *loginVc = [LoginViewController instantiate];
                [self.navigationController popToRootViewControllerAnimated:NO];
                [self.navigationController pushViewController:loginVc animated:YES];
            }];
        } else {
            [self showMessage:status.errorMessage];
        }
    }];
}

- (void) onResendClick {
    if(!self.currentUser) {
        return;
    }
    [self disableControls];
    [self execAsync:^{
        [self execOnUiThread:^{
            [self enableControls];
        }];
        MpinStatus *status = [MPinMFA RestartRegistration:self.currentUser];
        if(status.status == OK) {
            [self showMessage:[NSString stringWithFormat:@"Email has been sent to %@", [self.currentUser getIdentity]]];
        } else {
            [self showMessage: status.errorMessage];
        }
    }];
}

- (void) onEmailChanged:(NSString *)email {
    if(!self.submitButton.enabled && [self validateEmailWithString:email]) {
        [self disableControls];
        [self execAsync:^{
            [self enableControls];
            if(self.currentUser) {
                [MPinMFA DeleteUser:self.currentUser];
            }
            [self execOnUiThread:^{
                self.submitButton.hidden = NO;
            }];
            self.currentUser = nil;
        }];
    } else {
        if(email.length == 0 || ![self validateEmailWithString:email]) {
            self.submitButton.enabled = NO;
        } else {
            self.submitButton.enabled = YES;
        }
    }
}

-(void)resetViews {
    self.textField.text = @"";
    self.submitButton.enabled = YES;
    self.submitButton.hidden = NO;
}

- (void) onSubmitClick {
    NSString *email = self.textField.text;
    if(email.length == 0 || ![self validateEmailWithString:email]) {
        [self showMessage:@"Invalid email address entered"];
        return;
    }
    [self disableControls];
    AccessCodeServiceApi* api = [[AccessCodeServiceApi alloc] init];
    [api obtainAccessCode:^(NSString *accessCode, NSError *error) {
        [self execOnUiThread:^{
            if(error != nil) {
                [self enableControls];
                [self showMessage:error.localizedDescription];
            } else {
                [self enableControls];
                [AppDelegate delegate].accessCode = accessCode;
                [self onStartedRegistration:email];
            }
        }];
    }];
}

- (void) onStartedRegistration:(NSString *) email {
    [self disableControls];
    NSString *accessCode = [AppDelegate delegate].accessCode;
    [self execAsync:^{
        id<IUser> user = [MPinMFA MakeNewUser:email deviceName:@"iOS Sample App"];
        self.currentUser = user;
        MpinStatus *status = [MPinMFA StartRegistration:user accessCode:accessCode pmi: @""];
        if(status.status == OK) {
            [self execOnUiThread:^{
                self.submitButton.hidden = YES;
                self.infoLabel.text = [NSString stringWithFormat:@"Email has been sent to %@", email];
                self.resendEmailBtn.hidden = NO;
                self.confirmRegButton.hidden = NO;
                [self enableControls];
            }];
        }
    }];
}

- (void) enableControls {
    [self toggleControls: YES];
}

- (void) disableControls {
    [self toggleControls: NO];
}

- (void) toggleControls:(BOOL)enabled {
    [self execOnUiThread:^{
        self.submitButton.enabled = enabled;
        self.resendEmailBtn.enabled = enabled;
        self.confirmRegButton.enabled = enabled;
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
    
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self onEmailChanged: changedString];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self onEmailChanged: textField.text];
}

- (BOOL)validateEmailWithString:(NSString*)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
