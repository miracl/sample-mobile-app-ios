#import "RegCodeAuthenticationViewController.h"
#import <MfaSdk/MPinMFA.h>
#import "Config.h"
#import "APIManager.h"
#import "UIAlertController+MPinHelper.h"

@interface RegCodeAuthenticationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *regCodeTextField;
@end

@implementation RegCodeAuthenticationViewController

- (IBAction)regCodeAuthenticate:(id)sender
{
    NSString *mailTextFieldText = self.mailTextField.text;
    if (![self isValidEmail:mailTextFieldText]) {
        [self showMessage:@"Invalid email address"];
    }
    
    NSString *regCodeText = self.regCodeTextField.text;
    if (regCodeText.length != 6) {
        [self showMessage:@"Registration code should be 6 digits long"];
    }
    
    APIManager *apiManager = [[APIManager alloc] init];
    [apiManager getAccessCodeWithCompletionHandler:^(NSString *accessCode, NSError *error) {
        
        if (error != nil) {
            [self showMessage:@"Error when getting access code"];
            NSLog(@"Access Code obtaining error:%@", error.localizedDescription);
            return;
        }
        if (accessCode == nil || [accessCode isEqualToString:@""]){
            [self showMessage:@"No access code"];
        }
        
        BOOL isExisiting = [MPinMFA IsUserExisting:mailTextFieldText customerId:[Config companyId] appId:@""];
        if (isExisiting) {
            [self showMessage:@"User already registered"];
            return;
        }
        
        id<IUser> user = [MPinMFA MakeNewUser:mailTextFieldText
                                   deviceName:@"Device name"];
        
        MpinStatus *registationStatus = [MPinMFA StartRegistration:user
                                                        accessCode:accessCode
                                                           regCode:regCodeText
                                                               pmi:@""];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (registationStatus.status == OK){
                [self presentEnterPinAlertForUser:user];
            } else {
                [self mPinOperationFailedWithStatus:registationStatus];
            }
        });
    }];
}

-(void) presentEnterPinAlertForUser:(id<IUser>)user
{
    __block UIAlertController *alertController = [UIAlertController enterPinAlertControllerForUserIdentity:[user getIdentity] andSubmitHandler:^(NSString *enteredPin){
        if (enteredPin.length != 4) {
            [self showMessage:@"PIN must be 4 symbols"];
            return;
        }
        
        [self presentConfirmPinAlertControllerForEnteredPin:enteredPin andUser:user];
    }];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

-(void)presentConfirmPinAlertControllerForEnteredPin:(NSString *)enteredPin andUser:(id<IUser>)user
{
    __block UIAlertController *alertController = [UIAlertController confirmPinAlertControllerForUserIdentity:[user getIdentity] enteredPin:enteredPin andSubmitHandler:^(bool isPinConfirmed) {
        
        if (enteredPin.length != 4) {
            [self showMessage:@"PIN must be 4 symbols"];
            return;
        }
        
        
        if(!isPinConfirmed){
            [self showMessage:@"PIN Codes doesn't match.Please try again"];
            return;
        }
        
        MpinStatus *confirmationStatus = [MPinMFA ConfirmRegistration:user];
        if (confirmationStatus.status == OK) {
            MpinStatus *finishRegistrationStatus = [MPinMFA FinishRegistration:user
                                                                          pin0:enteredPin
                                                                          pin1:nil];
            if (finishRegistrationStatus.status == OK) {
                [self showMessage:@"Successful registration"];
                self.mailTextField.text = @"";
                self.regCodeTextField.text = @"";
            } else {
                [self mPinOperationFailedWithStatus:finishRegistrationStatus];
            }
        } else {
            [self mPinOperationFailedWithStatus:confirmationStatus];
        }
        
    }];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.mailTextField endEditing:YES];
    [self.regCodeTextField endEditing:YES];
}
@end
