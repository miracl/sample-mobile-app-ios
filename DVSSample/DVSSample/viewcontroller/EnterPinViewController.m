#import "EnterPinViewController.h"

@implementation EnterPinViewController

+ (EnterPinViewController*) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"EnterPinViewController"];
}

- (IBAction)onPinEntered:(id)sender {
    NSString *pin = self.textField.text;
    if(pin.length != 4) {
        [self showMessage:@"PIN length must be 4 characters long"];
        return;
    }
    self.pinCallback(pin);
}

- (IBAction)onPinCancel:(id)sender {
    self.pinCancelCallback();
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
