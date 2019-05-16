#import "EnterPinViewController.h"

@interface EnterPinViewController()

@property (weak, nonatomic) IBOutlet UILabel *pinPurposeLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSString *purposeString;

@end
@implementation EnterPinViewController

+ (EnterPinViewController*) instantiate: (NSString *) title {
    EnterPinViewController *pinViewController = [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"EnterPinViewController"];

    pinViewController.purposeString = title;
    
    return pinViewController;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.pinPurposeLabel.text = self.purposeString;
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
    if(self.pinCancelCallback) {
        self.pinCancelCallback();
    }
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
