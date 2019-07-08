#import "RegisterUserViewController.h"
#import "Config.h"
#import "APIManager.h"
#import "UIAlertController+MPinHelper.h"

@interface RegisterUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@end

@implementation RegisterUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.confirmButton.hidden = YES;
}

- (IBAction)registerIdentity:(id)sender
{
    APIManager *apiManager = [[APIManager alloc] init];
    NSString *text = self.userIDTextField.text;
    [self.userIDTextField resignFirstResponder];
   
    [apiManager getAccessCodeWithCompletionHandler:^(NSString *accessCode, NSError *error) {
        
        if (error != nil) {
            [self showMessage:@"Error when getting access code"];
            NSLog(@"Access Code obtaining error:%@", error.localizedDescription);
            return;
        }
        
        if (accessCode == nil || [accessCode isEqualToString:@""]){
            [self showMessage:@"No access code"];
        }
        
        
        self.currentUser = [MPinMFA MakeNewUser:text
                                     deviceName:@"Device name"];
        
        MpinStatus *registationStatus = [MPinMFA StartRegistration:self.currentUser
                                                        accessCode:accessCode
                                                               pmi:@""];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(registationStatus.status == OK){
                self.confirmButton.hidden = NO;
                self.registerButton.hidden = YES;
            } else {
                [self mPinOperationFailedWithStatus:registationStatus];
            }
        });
    }];
}

- (IBAction)confirm:(id)sender
{
    MpinStatus *confirmationStatus = [MPinMFA ConfirmRegistration:self.currentUser];
    if (confirmationStatus.status == OK) {
        
        __block UIAlertController *alertController = [UIAlertController enterPinAlertControllerForUserIdentity:self.userIDTextField.text andSubmitHandler:^(NSString *enteredPin) {
            
            if (enteredPin.length != 4) {
                [self showMessage:@"PIN must be 4 symbols"];
                return;
            }
            
             [self presentConfirmPinAlertControllerForEnteredPin:enteredPin];
        }];

        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    } else {
        [self mPinOperationFailedWithStatus:confirmationStatus];
    }
}

-(void)presentConfirmPinAlertControllerForEnteredPin:(NSString *)enteredPin
{
    __block UIAlertController *alertController = [UIAlertController confirmPinAlertControllerForUserIdentity:self.userIDTextField.text enteredPin:enteredPin andSubmitHandler:^(bool isPinConfirmed) {
        
        if (enteredPin.length != 4) {
            [self showMessage:@"PIN must be 4 symbols"];
            return;
        }
        
        if(!isPinConfirmed){
            [self showMessage:@"PIN Codes doesn't match.Please try again"];
            return;
        }
        
        MpinStatus *finishRegistrationStatus = [MPinMFA FinishRegistration:self.currentUser
                                                                      pin0:alertController.textFields[0].text
                                                                      pin1:@""];
        if (finishRegistrationStatus.status == OK) {
            [self.navigationController performSegueWithIdentifier:@"registerNewUserUnwindSegue"
                                                           sender:nil];
        } else {
            [self mPinOperationFailedWithStatus:finishRegistrationStatus];
        }

    }];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];

}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userIDTextField endEditing:YES];
}

@end
