#import "SignMessageViewController.h"
#import "AccessCodeServiceApi.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>
#import "AppDelegate.h"
#import "EnterPinViewController.h"

@interface SignMessageViewController ()

@property (nonatomic, strong) AppDelegate* appDelegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btnSign;

@end

@implementation SignMessageViewController

+ (SignMessageViewController*) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"SignMessageViewController"];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = [AppDelegate delegate];
    NSString *email = [self.currentUser getIdentity];
    self.titleLabel.text = [NSString stringWithFormat: @"An identity %@ has been registered for DVS. Now you can sign documents with it.", email];
    self.textField.delegate = self;
    [self.btnSign addTarget:self action:@selector(onSignClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void) onSignClick {
    [self.textField resignFirstResponder];
    __weak EnterPinViewController *enterPinController = [EnterPinViewController instantiate:@"Enter pin for signing"];
    enterPinController.pinCallback = ^(NSString *pin) {
        [enterPinController dismissViewControllerAnimated:YES completion:^{
            [self onPinEntered:pin];
        }];
    };
    enterPinController.pinCancelCallback = ^{
        [enterPinController dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:enterPinController animated:YES completion:nil];
}

- (void) onPinEntered:(NSString*) pin {
    NSString *message = self.textField.text;
    [self createDocumentHash:pin message:message];
}

- (void) createDocumentHash:(NSString*) pin message:(NSString*) message {
    AccessCodeServiceApi *api = [[AccessCodeServiceApi alloc] init];
    [api createDocumentHash:message withCallback:^(NSError *error, DocumentDvsInfo *info) {
        if(error) {
            NSString *errorMessage = [NSString stringWithFormat:@"Create document hash failed with error: %@", error.localizedDescription];
            [self showMessage:errorMessage];
        } else {
            id<IUser> user = self.appDelegate.currentUser;
            double time = (double)info.timestamp;
            BridgeSignature *bridgeSignature = nil;
            MpinStatus *status = [MPinMFA Sign:user documentHash:[info.hashValue dataUsingEncoding:NSUTF8StringEncoding] pin0:pin pin1:nil epochTime:time result:&bridgeSignature];
            if(status.status == OK) {
                [self verifySignature:bridgeSignature documentDvsInfo:info];
            } else {
                [self showMessage:[NSString stringWithFormat:@"Signing failed with error: %@", status.errorMessage]];
            }
        }
    }];
}

- (void) verifySignature:(BridgeSignature *) signature documentDvsInfo:(DocumentDvsInfo*) info {
    NSString *verificationData = [info serializeSignature:signature];
    NSString *documentData = [info serializeDocumentDvsInfo:info];
    AccessCodeServiceApi *api = [[AccessCodeServiceApi alloc] init];
    [api verifySignature:verificationData documentData:documentData withCallback:^(NSString *result, NSError *error) {
        if(error) {
            [self showMessage: error.localizedDescription];
        } else {
            [self showMessage: result];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
