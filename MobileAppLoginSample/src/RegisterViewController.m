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

#import "RegisterViewController.h"
#import "PinPadViewController.h"
#import <MfaSdk/MPinMFA.h>
#import <MfaSdk/MpinStatus.h>
#import "Utils.h"
#import "Config.h"

@interface RegisterViewController ()
{
    BOOL _boolBackendSet;
}
@property (nonatomic, strong) id<IUser> user;

- (IBAction)resendEmail:(id)sender;
- (IBAction)confirmEmail:(id)sender;
- (IBAction)addID:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)deleteID:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MPinMFA initSDK];
    [MPinMFA SetClientId:[Config companyId]];
    NSArray *domains = [Config trustedDomains];
    for(NSString *domain in domains) {
        [MPinMFA AddTrustedDomain: domain];
    }
    
    [_txtAddUser addTarget:self action:@selector(addID:) forControlEvents:UIControlEventEditingDidEndOnExit];
    _txtAddUser.keyboardType = UIKeyboardTypeEmailAddress;
    _txtAddUser.autocorrectionType = UITextAutocorrectionTypeNo;
    [_txtAddUser becomeFirstResponder];
    
    self.title = @"InAppLogin sample";
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _constraintTopSpaceInfoView.constant = 8;
    _constraintTopSpaceRegistered.constant = 8;
    _constraintTopSpaceStartedRegistration.constant = 8;
    [self setBackend];
    NSArray *arrUsers = [MPinMFA listUsers];
    
    if( arrUsers.count == 0 )
    {
        [self setupAddId];
    }
    else
    {
        [_txtAddUser resignFirstResponder];
        _viewAddId.alpha = 0.0;
        _viewStartedRegistration.alpha = 1.0;
        if ( arrUsers.count > 1 )
        {
            for (int i = 0; i < arrUsers.count; i++)
            {
                [MPinMFA DeleteUser:arrUsers[i]];
            }
            [self setupAddId];
        }
        else
        {
            _user = arrUsers[0];
            switch ([_user getState])
            {
                case INVALID:
                    [MPinMFA DeleteUser:_user];
                    _user = nil;
                    [self setupAddId];
                    break;
                case REGISTERED:
                    [self setupRegistered];
                    break;
                case BLOCKED:
                    [self setupBlocked];
                    break;
                case STARTED_REGISTRATION:
                    [self setupStartedRegistration];
                    break;
                default:
                    _user = nil;
                    [self setupAddId];
                    break;
            }
        }
    }
}



- ( void ) setupAddId
{
    _viewInfo.alpha = 0.0;
    _viewStartedRegistration.alpha = 0.0;
    _viewAddId.alpha = 1.0;
    _viewRegistered.alpha = 0;
}

- (void) setupStartedRegistration
{
    _viewStartedRegistration.alpha = 1.0;
    _viewAddId.alpha = 0.0;
    _viewInfo.alpha = 1.0;
    _viewRegistered.alpha = 0;
    _constraintTopSpaceStartedRegistration.constant = _viewInfo.frame.size.height + 16;
    _lblState.text      = [NSString stringWithFormat:@"State: %@",[self stateToString:[_user getState]] ];
    _lblBackend.text    = [NSString stringWithFormat:@"Backend: %@", [_user getBackend]];
    _lblIdentity.text   = [NSString stringWithFormat:@"ID: %@",[_user getIdentity]];
    _lblCustomerId.text = [NSString stringWithFormat:@"Customer: %@",[_user getCustomerId]];
    
}

- (void) setupRegistered
{
    _viewInfo.alpha = 1.0;
    _viewStartedRegistration.alpha = 0;
    _viewRegistered.alpha = 1;
    _constraintTopSpaceRegistered.constant = _viewInfo.frame.size.height + 16;
    _lblState.text      = [NSString stringWithFormat:@"State: %@",[self stateToString:[_user getState]] ];
    _lblBackend.text    = [NSString stringWithFormat:@"Backend: %@", [_user getBackend]];
    _lblIdentity.text   = [NSString stringWithFormat:@"ID: %@",[_user getIdentity]];
    _lblCustomerId.text = [NSString stringWithFormat:@"Customer: %@",[_user getCustomerId]];
    
}


- (void) setupBlocked
{
    [self deleteID:nil];
}

- (void) showAlert:(NSString*)title withBody:(NSString *)body {
    [Utils showAlert:self withTitle:title withBody:body];
}

- ( void ) getAccessCode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSURL *theUrl = [NSURL URLWithString:[Config authzUrl]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        [request setTimeoutInterval:10];
        request.HTTPMethod = @"POST";
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable jsonData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if(error != nil)    {
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    [self showAlert:@"Error" withBody:error.description];
                });
            }
            else if (httpResponse.statusCode == 412)
            {
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    [self showAlert:@"Error" withBody:@"Deprecated version"];
                });
            }
            else if(httpResponse.statusCode == 406) {
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    [self showAlert:@"Error" withBody:@"You cannot use this app to login to this service."];
                });
            }
            else
            {
                [self accessCodeReaded:jsonData];
            }
        }] resume];
    });
}

- ( void ) accessCodeReaded: (NSData *)jsonData {
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    
    NSString *strAccessCode;
    MpinStatus *mpinStatus  = [MPinMFA GetAccessCode:jsonObject[@"authorizeURL"] accessCode:&strAccessCode];
    switch (mpinStatus.status) {
        case OK:
            NSLog(@"%@", strAccessCode);
            _accessCode  = strAccessCode;
            break;
            
        default:
            [self showError:mpinStatus.errorMessage];
            break;
    }
}

- ( void ) startAuthentication
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        MpinStatus *mpinStatus = [MPinMFA StartAuthentication:self.user accessCode:self.accessCode];
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            ///  NSLog(@"%@",[user GetMPinId]);
            if ( mpinStatus.status == OK )  {
                PinPadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
                vc.accessCode = self.accessCode;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                NSString * errorMsg = [NSString stringWithFormat:@"An error has occurred during Start Authentication Method invocation: Info - %@", mpinStatus.statusCodeAsString];
                [self showAlert:@"Error" withBody:errorMsg];
            }
        });
    });
}

- ( void ) addUser
{
    NSString *strUserName = _txtAddUser.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        self.user = [MPinMFA MakeNewUser:strUserName deviceName:@"SampleDevName"];
        MpinStatus *mpinStatus = [MPinMFA StartRegistration:self.user accessCode:self.accessCode pmi:@""];
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            [self.btnAdd setEnabled:YES];
            if ( mpinStatus.status == OK )  {
                [self.txtAddUser resignFirstResponder];
                [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self setupStartedRegistration];
                } completion:nil];
            }   else    {
                self.txtAddUser.text = @"";
                self.user = nil;
                self.txtAddUser.placeholder = @"Please enter your emial!";
                [self showAlert:@"Error" withBody:[NSString stringWithFormat:@"An error has occurred during user registration! Info - %@",mpinStatus.statusCodeAsString]];
            }
        });
    });
}

- ( void ) showError:(NSString *)description
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:description
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
        
        [alert addAction:yesButton];
        alert.view.alpha = 1.0;
        alert.view.backgroundColor = [UIColor whiteColor];
        alert.view.layer.cornerRadius = 8.0;
        alert.view.clipsToBounds = YES;
        [self presentViewController:alert animated:YES completion:nil];
    });
}

/*
 This method checks whether user has confirmed its identity via activation link that is send to user's mail inbox. 
 if user has clicked on activation link then the apps navigates user to Set up pin page.
 If user has not cliecked on activation link he is prompted to do so via tips message on the screen shown for 3 seconds
 */

- ( void ) confirmRegistration
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        MpinStatus *mpinStatus = [MPinMFA ConfirmRegistration:self.user];
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            
            NSLog(@"%@", mpinStatus.statusCodeAsString);
            
            if ( mpinStatus.status == OK )  {
                PinPadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
                vc.accessCode = self.accessCode;
                [self.navigationController pushViewController:vc animated:YES];
            } else  {
                [self showAlert:@"Error" withBody:[NSString stringWithFormat:@"An error has occurred during confirming registration! Info - %@", mpinStatus.statusCodeAsString]];
            }
        });
    });

}
#pragma mark - Actions -

- (IBAction)confirmEmail:(id)sender
{
    if (_accessCode != nil && _boolBackendSet && [_user getState] == STARTED_REGISTRATION)
    {
        [self confirmRegistration];
    }
    else
    {
        [self showAlert:@"Error" withBody:@"Cannot confirm email!"];
    }
}


- ( IBAction) login:(id)sender
{
    [self startAuthentication];
}

- (IBAction)deleteID:(id)sender
{
    [MPinMFA DeleteUser:_user];
    [self setupAddId];
}


- (IBAction)resendEmail:(id)sender
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSString *strUserID = [self.user getIdentity];
        [MPinMFA DeleteUser:self.user];
        
        self.user = [MPinMFA MakeNewUser:strUserID deviceName:@"SampleDevName"];
        MpinStatus *mpinStatus = [MPinMFA StartRegistration:self.user
                                               accessCode:self.accessCode
                                                        pmi:@""];

        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            NSString * msg = ( mpinStatus.status == OK ) ? ( @"The Email has been resent" ) :
                                                            ([NSString stringWithFormat:@"An error has occurred! Info - %@", [mpinStatus getStatusCodeAsString]] );
            [self showAlert:@"Info" withBody:msg];
        });
    });
}


/*
 This initiate registration process. User identity is created and registered.
 */
- (IBAction)addID:(id)sender
{
    [_btnAdd setEnabled:NO];
    
    _txtAddUser.text = [_txtAddUser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _txtAddUser.text = [_txtAddUser.text lowercaseString];

    
    if ( ![Utils isValidEmail:_txtAddUser.text] )
    {
        [_btnAdd setEnabled:YES];
    }
    else
    {
        [self addUser];
    }
}

- ( BOOL )textFieldShouldReturn:( UITextField * )textField {
    [textField resignFirstResponder];
    return YES;
}

- ( BOOL )textFieldShouldBeginEditing:( UITextField * )textField {
    return YES;
}


- ( NSString *) stateToString :(UserState) state
{
    switch (state)
    {
        case INVALID:
            return @"INVALID";
            break;
        case STARTED_REGISTRATION:
            return @"STARTED REGISTRATION";
            break;
        case ACTIVATED:
            return @"ACTIVATED";
            break;
        case REGISTERED:
            return @"REGISTERED";
            break;
        case BLOCKED:
            return @"BLOCKED";
            break;
        default:
            break;
    }
    return @"";
}

- ( void ) setBackend
{
    MpinStatus *mpinStatus = [MPinMFA SetBackend: [Config authBackend]];
    switch (mpinStatus.status) {
        case OK:
            _boolBackendSet = YES;
            [self getAccessCode];
            break;
            
        default:
            [self showError:mpinStatus.errorMessage];
            _boolBackendSet = NO;
            break;
    }
}

@end
