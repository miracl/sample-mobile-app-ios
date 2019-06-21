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

#define PIN_LENGTH      4.0

#import "PinPadViewController.h"
#import "SuccessfulViewController.h"
#import "LoginSuccessfulViewController.h"
#import "ErrorHandler.h"
#import <MfaSdk/MPinMFA.h>
#import "Config.h"

@interface PinPadViewController ()

@property (nonatomic, weak) IBOutlet UILabel        *lblIdentity;
@property (nonatomic, weak) IBOutlet UIButton       *btnSend;
@property (nonatomic, weak) IBOutlet UITextField    *txtPinPad;
@property (nonatomic, weak) IBOutlet UIView         *padView;

@property (nonatomic, strong) id<IUser> user;

- (void) textFieldText:(id)notification;
- (IBAction)onClickSendButton:(id)sender;

@end

@implementation PinPadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_txtPinPad becomeFirstResponder];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _user = [MPinMFA listUsers][0];
    _lblIdentity.text = [_user getIdentity];
    _txtPinPad.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (textFieldText:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_txtPinPad];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Event handlers -
/*
Once four digit pin is scraped from user interface onClickSendButton can be called via login button. It does the following:
Checks its state. Depending on its state it navigates app to different pages such as:
If user is in STARTED_REGISTRATION state then the pin is set up for this particular user.
If user is in REGISTERED state the user is able to be authenticated with using this pin. If the pin is correct the user is successfully authenticated and the apps navigates user to Login Successfull page. On wrong pin and appropriate error is shown. On 3 times enter wrong pin the user account is blocked and deleted from the user's backend list.
In any other User state an Error messge is shown.
*/
- (IBAction)onClickSendButton:(id)sender {
    if (_txtPinPad.text.length < PIN_LENGTH)
    {
        return;
    }
    
    if([_user getState] == STARTED_REGISTRATION) {
        NSString *strPIN = _txtPinPad.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            MpinStatus *mpinStatus = [MPinMFA FinishRegistration:self.user pin0:strPIN pin1:nil];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                if ( mpinStatus.status == OK )  {
                    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SuccessfulViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    NSString *strMessage =  [NSString stringWithFormat:@"An error has occurred during Finishing Registration! Info - %@ , the current user will be deleted!",
                                             mpinStatus.statusCodeAsString];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:strMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    [MPinMFA DeleteUser:self.user];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }
            });
        });
    }
    else if([_user getState] == REGISTERED)
    {
        NSString *strPIN = _txtPinPad.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString *strAuthzCode;
            MpinStatus *mpinStatus = [MPinMFA FinishAuthentication:self.user pin:strPIN pin1:nil accessCode:self.accessCode authzCode:&strAuthzCode];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                switch ([mpinStatus status]) {
                    case OK:
                        [self checkAuthenticationStatus:strAuthzCode];
                        break;
                    case INCORRECT_PIN:
                        if([self.user getState] == BLOCKED)
                        {
                            UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Error"
                                                                                             message:@"The current user has been blocked! The identity is going to be deleted!"
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                                                style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action){
                                                                                  [self.navigationController popToRootViewControllerAnimated:YES];
                                                                              }
                                                        ];
                            [alert addAction:yesButton];
                            alert.view.alpha = 1.0;
                            alert.view.backgroundColor = [UIColor whiteColor];
                            alert.view.layer.cornerRadius = 8.0;
                            alert.view.clipsToBounds = YES;
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        else
                        {
                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong PIN" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

                        }
                        self.txtPinPad.text = @"";
                        
                        
                        
                        break;
                    default:
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"User cannot be authenticated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        break;
                }
            });
        });
    }
    else if([_user getState] == BLOCKED)
    {
        UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Error"
                                                                         message:@"The current user has been blocked! The identity is going to be deleted!"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action){
                                                              [self.navigationController popToRootViewControllerAnimated:YES];
                                                          }
                                    ];
        [alert addAction:yesButton];
        alert.view.alpha = 1.0;
        alert.view.backgroundColor = [UIColor whiteColor];
        alert.view.layer.cornerRadius = 8.0;
        alert.view.clipsToBounds = YES;
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- ( void ) checkAuthenticationStatus:(NSString *) strAuthzCode
{
    NSURL *theUrl = [NSURL URLWithString: [Config authCheckUrl]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request setTimeoutInterval:10];
    request.HTTPMethod = @"POST";
    NSString *str = [NSString stringWithFormat:@"{ \"code\": \"%@\",\"userID\": \"%@\" }",strAuthzCode, [_user getIdentity]];
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    dispatch_async(dispatch_get_main_queue(), ^ (void) {
        if (response.statusCode != 200)
        {
            NSString *newStr = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:newStr
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        
        }
        else if ( error != nil )
        {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.description
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil] show];
        }
        else
        {
            UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Congrats"
                                                                             message:@"You have been logged in successfully"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Start over"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  [self.navigationController popToRootViewControllerAnimated:YES];
                                                              }
                                        ];
            [alert addAction:yesButton];
            alert.view.alpha = 1.0;
            alert.view.backgroundColor = [UIColor whiteColor];
            alert.view.layer.cornerRadius = 8.0;
            alert.view.clipsToBounds = YES;
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
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
