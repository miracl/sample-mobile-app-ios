/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#define CORNER_RADIUS   14.0
#define PIN_LENGTH      4.0

#import "PinPadViewController.h"
#import "SuccessfulViewController.h"
#import "LoginSuccessfulViewController.h"
#import "ErrorHandler.h"
#import "MPin.h"

@interface PinPadViewController ()

@property (nonatomic, weak) IBOutlet UILabel        *lblIdentity;
@property (nonatomic, weak) IBOutlet UIButton       *btnSend;
@property (nonatomic, weak) IBOutlet UITextField    *txtPinPad;
@property (nonatomic, weak) IBOutlet UIView         *padView;

@property (nonatomic, strong) id<IUser> user;

- (void) textFieldText:(id)notification;
- (void) blockedIdentityCase;
- (IBAction)onClickSendButton:(id)sender;

@end

@implementation PinPadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnSend.layer.cornerRadius  =   CORNER_RADIUS;
    _padView.layer.cornerRadius  =   CORNER_RADIUS;
    [_txtPinPad becomeFirstResponder];
}

- (void) viewWillAppear:(BOOL)animated {
    self.user = [MPin listUsers][0];
    _lblIdentity.text = [_user getIdentity];
    _txtPinPad.text = @"";
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (textFieldText:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_txtPinPad];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) blockedIdentityCase {
      [[ErrorHandler sharedManager] presentMessageInViewController:self
                                                       errorString:@"The current user has been blocked! The identity is going to be deleted!"
                                              addActivityIndicator:NO
                                                       minShowTime:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [MPin DeleteUser:self.user];
        [[ErrorHandler sharedManager] hideMessage];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

#pragma mark - Event handlers -

- (IBAction)onClickSendButton:(id)sender {
    if (_txtPinPad.text.length < PIN_LENGTH) return;
    
    [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"" addActivityIndicator:YES minShowTime:0.0];
    
    if([_user getState] == STARTED_REGISTRATION) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            MpinStatus *mpinStatus = [MPin FinishRegistration:_user pin:_txtPinPad.text];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                if ( mpinStatus.status == OK )  {
                    [[ErrorHandler sharedManager] hideMessage];
                    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SuccessfulViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    [[ErrorHandler sharedManager] updateMessage:[NSString stringWithFormat:@"An error has occured during Finishing Registration! Info - %@ , the current user will be deleted!",
                                                                 mpinStatus.statusCodeAsString]
                                           addActivityIndicator:NO
                                                      hideAfter:0.0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [MPin DeleteUser:self.user];
                        [[ErrorHandler sharedManager] hideMessage];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }
            });
        });
    } else if([_user getState] == REGISTERED) {
       /// TODO :: Call start authentication for QR VIEW Controller;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            MpinStatus *mpinStatus = [MPin FinishAuthenticationAN:_user pin:_txtPinPad.text accessNumber:_accessCode];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                if ( mpinStatus.status == OK )  {
                    [[ErrorHandler sharedManager] hideMessage];
                    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginSuccessfulViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                }   else if( mpinStatus.status == INCORRECT_PIN )   {
                    if( [_user getState] == BLOCKED ) {
                        [[ErrorHandler sharedManager] hideMessage];
                        [self blockedIdentityCase];
                    } else {
                        [[ErrorHandler sharedManager] updateMessage:@"Wrong PIN" addActivityIndicator:NO hideAfter:3];
                    }
                }  else {
                    NSString * errorMsg = ( mpinStatus.status == INCORRECT_ACCESS_NUMBER ) ? (@"Session expired!\nPlease refresh the webpage and scan the QR code again.") :
                                                    ([NSString stringWithFormat:@"An error has occured during user Authentication Info - %@", mpinStatus.statusCodeAsString]);
                    [[ErrorHandler sharedManager] updateMessage:errorMsg addActivityIndicator:NO hideAfter:0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [[ErrorHandler sharedManager] hideMessage];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }
            });
        });
    } else if([_user getState] == BLOCKED) {
        [[ErrorHandler sharedManager] hideMessage];
        [self blockedIdentityCase];
    }
}

- ( BOOL )textFieldShouldReturn:( UITextField * )textField {
    [textField resignFirstResponder];
    return YES;
}

- ( BOOL )textFieldShouldBeginEditing:( UITextField * )textField {
    return YES;
}

- (void) textFieldText:(id)notification {
    if(_txtPinPad.text.length >= PIN_LENGTH) {
        [_txtPinPad resignFirstResponder];
    }
}

@end
