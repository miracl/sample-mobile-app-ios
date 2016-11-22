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

#import "RegisterViewController.h"
#import "PinPadViewController.h"
#import "ErrorHandler.h"
#import "MPin.h"
#import "Utils.h"

@interface RegisterViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnConfirm;
@property (nonatomic, weak) IBOutlet UIButton *btnResend;
@property (nonatomic, weak) IBOutlet UIButton *btnAdd;

@property (nonatomic, weak) IBOutlet UITextField *txtAddUser;
@property (nonatomic, weak) IBOutlet UILabel *lblMsg;
@property (nonatomic, weak) IBOutlet UIView *addView;
@property (nonatomic, weak) IBOutlet UIView *confirmView;

@property (nonatomic, strong) id<IUser> user;

- (IBAction)onClickConfirmButton:(id)sender;
- (IBAction)onClickResendButton:(id)sender;
- (IBAction)onClickAddmButton:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_txtAddUser addTarget:self action:@selector(onClickAddmButton:) forControlEvents:UIControlEventEditingDidEndOnExit];
    _txtAddUser.keyboardType = UIKeyboardTypeEmailAddress;
    [_txtAddUser becomeFirstResponder];
    
    _btnConfirm.layer.cornerRadius  =    CORNER_RADIUS;
    _btnResend.layer.cornerRadius   =    CORNER_RADIUS;
    _btnAdd.layer.cornerRadius      =    CORNER_RADIUS;
    _addView.layer.cornerRadius     =    CORNER_RADIUS;
    _confirmView.layer.cornerRadius =    CORNER_RADIUS;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if( [MPin listUsers].count == 0 ) {
        /// TODO :: Remove this after hoock it up !!
        self.confirmView.alpha = 1.0;
        self.addView.alpha = 1.0;
    } else {
        self.addView.alpha = 0.0;
        self.confirmView.alpha = 1.0;
        self.user = [MPin listUsers][0];
        self.lblMsg.text = [NSString stringWithFormat:@"Your Identity %@ has ben created!", [self.user getIdentity]];
    }
}

#pragma mark - Event handlers -

- (IBAction)onClickConfirmButton:(id)sender {

    if([self.user getState] == STARTED_REGISTRATION) {
        [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"" addActivityIndicator:YES minShowTime:0.0];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            MpinStatus *mpinStatus = [MPin ConfirmRegistration:self.user pushNotificationIdentifier:nil];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                if ( mpinStatus.status == OK )  {
                    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                } else  {
                
                    [[ErrorHandler sharedManager] updateMessage:[NSString stringWithFormat:@"An error has occured during confirming registration! Info - %@", mpinStatus.statusCodeAsString]
                                           addActivityIndicator:NO
                                                      hideAfter:3.0];
                }
            });
        });
    } else {
        [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"The user is not in Started Registration state!"
                                                addActivityIndicator:YES
                                                         minShowTime:3.0];
    }
}
- (IBAction)onClickResendButton:(id)sender {

    PinPadViewController *ppvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
    [self.navigationController pushViewController:ppvc animated:YES];

    /// TODO :: REMOVE ±THIDS after hook it up!!!
    /*
    [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"" addActivityIndicator:YES minShowTime:0.0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        MpinStatus *mpinStatus = [MPin RestartRegistration:self.user userData:@""];
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            NSString * msg = ( mpinStatus.status == OK ) ? ( @"OK" ) :
                                                            ([NSString stringWithFormat:@"An error has occured! Info - %@", [mpinStatus getStatusCodeAsString]] );
            [[ErrorHandler sharedManager] updateMessage:msg
                                   addActivityIndicator:NO
                                              hideAfter:3.0];
        });
    });
     */
}

- (IBAction)onClickAddmButton:(id)sender {
    [_btnAdd setEnabled:NO];
    _txtAddUser.text = [_txtAddUser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _txtAddUser.text = [_txtAddUser.text lowercaseString];

    if ( ![Utils isValidEmail:_txtAddUser.text] )
    {
        [[ErrorHandler sharedManager] presentMessageInViewController:self
                                                         errorString:@"Please enter a valid email!"
                                                addActivityIndicator:NO
                                                         minShowTime:3];
        [_btnAdd setEnabled:YES];
        return;
    }
    
    id<IUser> user  = [MPin getIUserById:_txtAddUser.text];
    if(user != nil) {
        [[ErrorHandler sharedManager] presentMessageInViewController:self
                                                         errorString:@"This identity already exists."
                                                addActivityIndicator:NO
                                                         minShowTime:3];
        [_btnAdd setEnabled:YES];
        return;
    }
    
    [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"" addActivityIndicator:YES minShowTime:0.0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        self.user = [MPin MakeNewUser:_txtAddUser.text deviceName:@"SampleDevName"];
        MpinStatus *mpinStatus = [MPin StartRegistration:self.user userData:@""];
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            [_btnAdd setEnabled:YES];
            if ( mpinStatus.status == OK )  {
                [[ErrorHandler sharedManager] hideMessage];
                self.lblMsg.text = [NSString stringWithFormat:@"Your Identity %@ has ben created!", [self.user getIdentity]];
                [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.addView.alpha = 0.0;
                    self.confirmView.alpha = 1.0;
                } completion:nil];
            }   else    {
                _txtAddUser.text = @"";
                self.user = nil;
                _txtAddUser.placeholder = @"Please enter your emial!";
                [[ErrorHandler sharedManager] updateMessage:[NSString stringWithFormat:@"An error has occured during user registration! Info - %@",mpinStatus.statusCodeAsString]
                                       addActivityIndicator:NO
                                                  hideAfter:3.0];
            }
        });
    });
}

- ( BOOL )textFieldShouldReturn:( UITextField * )textField {
    [textField resignFirstResponder];
    return YES;
}

- ( BOOL )textFieldShouldBeginEditing:( UITextField * )textField {
    return YES;
}

@end
