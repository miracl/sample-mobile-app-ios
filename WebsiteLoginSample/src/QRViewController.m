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

#import <AVFoundation/AVFoundation.h>
#import "QRViewController.h"
#import "RegisterViewController.h"
#import <MPinSDK/MPinMFA.h>
#import "ATMHud.h"
#import "ErrorHandler.h"
#import "Config.h"

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property ( nonatomic, strong ) AVCaptureSession            *captureSession;
@property ( nonatomic, strong ) AVCaptureDevice             *captureDevice;
@property ( nonatomic, strong ) AVCaptureDeviceInput        *captureInput;
@property ( nonatomic, strong ) AVCaptureVideoPreviewLayer  *videoPreviewLayer;
@property ( nonatomic, strong ) ATMHud *hud;

- ( void ) serviceReaded: (NSData *)service accessCode:(NSString *) accessCode;
- (void) onSetBackendCompleted:(NSString *) accessCode;

@end

@implementation QRViewController

/*
On application launch the MPIN sdk must be initialized! In our sample app we need to pass to sdk an CID. It is required by the Authentication backend.
 Without it each HTTP call will fail. Once the sdk is initialized , we must set backend against each user is going to be authenticated.
 The sample app extract this information from QR code. QR code contains and access code as well in order to support web login flow. 
 That's why here int QRViewController class we initialize and run iPhone / iPad camera. 
 In viewDidLoad mehtod we initialize SDK and configure camera.
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error;
    [MPinMFA initSDK];
    
    [MPinMFA SetClientId:[Config companyId]];
    for(NSString *domain in [Config trustedDomains]) {
        [MPinMFA AddTrustedDomain: domain];
    }
    
    _hud = [ATMHud new];
    _captureSession = [[AVCaptureSession alloc] init];
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    if (error.code == -11852) {
        [[[UIAlertView alloc] initWithTitle:@"Camera permission needed"
                                    message:@"No camera permission"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]
         show];
    }
    else if ( error != nil )
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:error.description
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]
         show];
    }
    else if ( [_captureSession canAddInput:_captureInput] )
    {
        [_captureSession addInput:_captureInput];
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        if ( [_captureSession canAddOutput:captureMetadataOutput] )
        {
            [_captureSession addOutput:captureMetadataOutput];
            dispatch_queue_t dispatchQueue;
            dispatchQueue = dispatch_queue_create("myQueue", NULL);
            [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
            [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
            _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [_viewPreview.layer insertSublayer:_videoPreviewLayer atIndex:0];
        }
    }
}

/*
in viewDidAppear mehtod we run camera
 */
- ( void ) viewDidAppear:( BOOL )animated
{
    [super viewDidAppear:animated];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    if ( _captureInput )
    {
        if (!_captureSession.isRunning)
        {
            [self startReading];
        }
    }
}

-( void ) startReading
{
    self.accessCode = nil;
    if (!_captureSession.isRunning)
    {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if ( status == AVAuthorizationStatusAuthorized ) // authorized
        {
            NSLog(@"Starting read session");
            [_captureSession startRunning];
        }
        else if ( status == AVAuthorizationStatusDenied )
        {
            [[[UIAlertView alloc] initWithTitle:@"Not authorized"
                                        message:@"The application needs permissions to use the camera in order to have full functionality."
                                       delegate:nil
                              cancelButtonTitle:@"Go to settings"
                              otherButtonTitles: nil]
             show];
        }
        else if ( status == AVAuthorizationStatusRestricted )
        {
            [[[UIAlertView alloc] initWithTitle:@"Not authorized"
                                        message:@"The application needs permissions to use the camera in order to have full functionality."
                                       delegate:nil
                              cancelButtonTitle:@"Go to settings"
                              otherButtonTitles: nil]
             show];
            
        }
        else if ( status == AVAuthorizationStatusNotDetermined )
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
                if ( granted )
                {
                    [self startReading];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:@"Not authorized"
                                                message:@"The application needs permissions to use the camera in order to have full functionality."
                                               delegate:nil
                                      cancelButtonTitle:@"Go to settings"
                                      otherButtonTitles: nil]
                     show];
                }
            }];
        }
    }
}

-( void ) stopReading
{
    if (_captureSession.isRunning)
    {
        NSLog(@"Stoping read session");
        [_captureSession stopRunning];
    }
}

/*
HERE Once the QR Code has been successfully detected the mehtod captureOutput is called and we are ready to parse raw information that comes from qr code.
 */
-( void )captureOutput:( AVCaptureOutput * )captureOutput didOutputMetadataObjects:( NSArray * )metadataObjects fromConnection:( AVCaptureConnection * )connection
{
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
    if ( [[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] )
    {
        [self stopReading];
        NSLog(@"%@",[metadataObj stringValue]);
        [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"" addActivityIndicator:YES minShowTime:0];
        [self parseResponse:[metadataObj stringValue]];
    }
}

/*
 The routine parseResponse extracts the QR code raw information. The extracted information is represented as JSON data structure and it is passed to serviceReaded method for further processing.
*/
- ( void ) parseResponse:( NSString * ) strResponse
{
    NSRange range = [strResponse rangeOfString:@"#"];
    if ( range.location != NSNotFound )
    {
        NSString *strBaseURL = [strResponse substringToIndex:range.location];
        NSString *strCode   = [strResponse substringFromIndex:range.location + 1];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSHTTPURLResponse *response;
            NSError *error;
            NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/service",strBaseURL]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            [request setTimeoutInterval:10];
            request.HTTPMethod = @"GET";
            
            [request setValue:[Config companyId] forHTTPHeaderField:@"X-MIRACL-CID"];
            
            NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if(error != nil)    {
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    [[ErrorHandler sharedManager] hideMessage];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:error.description
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                });
            }
            else if (response.statusCode == 412)
            {
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    [[ErrorHandler sharedManager] hideMessage];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:@"Deprecated version"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                });
            }
            else if(response.statusCode == 406) {
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    [[ErrorHandler sharedManager] hideMessage];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:@"You cannot use this app to login to this service."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                });
            }
            else
            {
                [self serviceReaded:jsonData accessCode:strCode];
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            [[ErrorHandler sharedManager] hideMessage];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid QR!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC), dispatch_get_main_queue(), ^ (void){
                [self performSelectorOnMainThread:@selector( startReading ) withObject:nil waitUntilDone:NO];
            });
        });
    }
    
}

/*
Service paramenter of serviceReaded method contains backend url that each user will be able to register and authenticated. If SDK mehtod SetBackend completes successfully then onSetBackendCompleted method is called with additional parameter access code for web login flow.
*/
- ( void ) serviceReaded: (NSData *)service accessCode:(NSString *) accessCode
{
    self.accessCode = accessCode;
    if ( service != nil )
    {
        NSError *error;
        NSDictionary *config = [NSJSONSerialization JSONObjectWithData:service options:kNilOptions error:&error];
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                [[ErrorHandler sharedManager] hideMessage];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.description
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                
            });
        }
        else if(config[@"url"] == nil || config[@"type"] == nil || config[@"name"] == nil || config[@"logo_url"] == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                [[ErrorHandler sharedManager] hideMessage];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Invalid configuration"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
            });
        }   else    {
            MpinStatus *mpinStatus = [MPinMFA SetBackend:config[@"url"]];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                if ( mpinStatus.status == OK )  {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self onSetBackendCompleted:accessCode];
                    });
                }
                else
                {
                    [[ErrorHandler sharedManager] updateMessage:[NSString stringWithFormat:@"Set BackEnd Error: %ld", (long)mpinStatus.status] addActivityIndicator:NO hideAfter:0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ (void){
                        [[ErrorHandler sharedManager] hideMessage];
                        [self  startReading];
                    });

                }
            });
        }
    }   else    {
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            [[ErrorHandler sharedManager] hideMessage];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Service unavailable!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        });
    }
}

/*
 onSetBackendCompleted does the following: Checks whether there are any user for that particular backend. If they are not then it navigates app to User Registration page. 
 If there is an user then it checks its state. Depending on its state it navigates app to different pages such as: 
 If user is in STARTED_REGISTRATION state the app navigate user ot finish registration stage. Registration page is responsible to handle this case.
 If user is in REGISTERED then the user is navigated to Authentication page - PinPadViewController wich is responsible to authenticate user.
 In any other User state an Error messge is shown.
*/
- (void) onSetBackendCompleted:(NSString *) accessCode {
    NSArray* arr = [MPinMFA listUsers];
    if (arr.count == 0) {
        [[ErrorHandler sharedManager] hideMessage];
        RegisterViewController *vc = (RegisterViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                                                instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        vc.accessCode = accessCode;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        id<IUser> user  = arr[0];
        if([user getState] == STARTED_REGISTRATION) {
            [[ErrorHandler sharedManager] hideMessage];
            RegisterViewController *vc = (RegisterViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                                                    instantiateViewControllerWithIdentifier:@"RegisterViewController"];
            vc.accessCode = accessCode;
            [self.navigationController pushViewController:vc animated:YES];
        } else if([user getState] == REGISTERED )  {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                MpinStatus *mpinStatus = [MPinMFA StartAuthentication:user accessCode:accessCode];
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
                    ///  NSLog(@"%@",[user GetMPinId]);
                    if ( mpinStatus.status == OK )  {
                        [[ErrorHandler sharedManager] hideMessage];
                        UIViewController *vc = (UIViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
                        [self.navigationController pushViewController:vc animated:YES];
                    }   else {
                        NSString * errorMsg = [NSString stringWithFormat:@"An error has occured during Start Authentication Method invocation: Info - %@", mpinStatus.statusCodeAsString];
                        [[ErrorHandler sharedManager] updateMessage:errorMsg addActivityIndicator:NO hideAfter:3];
                    }
                });
            });
        } else {
            [[ErrorHandler sharedManager] updateMessage:@"User is INVALID OR BLOCKED STATE!" addActivityIndicator:NO hideAfter:3];
        }
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self  startReading];
}

@end
