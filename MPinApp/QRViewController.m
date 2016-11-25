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
#import "MPin.h"
#import "ATMHud.h"
#import "ErrorHandler.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error;
    [MPin initSDKWithHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"com.miracl.maas.ddmfa/1.1.0 (ios/10.1.1) build/186",@"User-Agent", nil]];
    _hud = [ATMHud new];
    _captureSession = [[AVCaptureSession alloc] init];
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    if (error.code == -11852) {
        [[[UIAlertView alloc] initWithTitle:@"Camera permission needed"
                                    message:@"No camera permission"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]
         show];
    }
    else if ( error != nil )
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:error.description
                                   delegate:self
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
                                       delegate:self
                              cancelButtonTitle:@"Go to settings"
                              otherButtonTitles: nil]
             show];
        }
        else if ( status == AVAuthorizationStatusRestricted )
        {
            [[[UIAlertView alloc] initWithTitle:@"Not authorized"
                                        message:@"The application needs permissions to use the camera in order to have full functionality."
                                       delegate:self
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
                                               delegate:self
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

-( void )captureOutput:( AVCaptureOutput * )captureOutput didOutputMetadataObjects:( NSArray * )metadataObjects fromConnection:( AVCaptureConnection * )connection
{
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
    if ( [[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] )
    {
        [self stopReading];
        NSLog(@"%@",[metadataObj stringValue]);
        [self parseResponse:[metadataObj stringValue]];
    }
}

- ( void ) parseResponse:( NSString * ) strResponse
{
    NSRange range = [strResponse rangeOfString:@"#"];
    if ( range.location != NSNotFound )
    {
        NSString *strBaseURL = [strResponse substringToIndex:range.location];
        NSString *strCode   = [strResponse substringFromIndex:range.location + 1];
        NSLog(@"%@ , %@", strBaseURL, strCode);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSHTTPURLResponse *response;
            NSError *error;
            NSURL *theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/service",strBaseURL]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            [request setTimeoutInterval:10];
            request.HTTPMethod = @"GET";
            [request setValue:@"com.miracl.maas.ddmfa/1.1.0 (ios/10.1.1) build/186" forHTTPHeaderField:@"User-Agent"];
            NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if(error != nil)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.description
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else if (response.statusCode == 412)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Deprecated version"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else if(response.statusCode == 406) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"You cannot use this app to login to this service."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid QR!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC), dispatch_get_main_queue(), ^ (void){
                [self performSelectorOnMainThread:@selector( startReading ) withObject:nil waitUntilDone:NO];
            });
        });
    }
    
}

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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.description
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                
            });
        }
        else if(config[@"url"] == nil || config[@"rps_prefix"] == nil || config[@"type"] == nil || config[@"name"] == nil || config[@"logo_url"] == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Invalid configuration"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
            });
        }   else    {
            MpinStatus *mpinStatus = [MPin SetBackend:config[@"url"] rpsPrefix:config[@"rps_prefix"]];
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                if ( mpinStatus.status == OK )  {
                    [[ErrorHandler sharedManager] presentMessageInViewController:self errorString:@"" addActivityIndicator:YES minShowTime:0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self onSetBackendCompleted:accessCode];
                    });
                }
                else
                {
                    [[ErrorHandler sharedManager] presentMessageInViewController:self
                                                                     errorString:[NSString stringWithFormat:@"Set BackEnd Error: %ld", (long)mpinStatus.status]
                                                            addActivityIndicator:NO
                                                                     minShowTime:0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ (void){
                        [[ErrorHandler sharedManager] hideMessage];
                        [self  startReading];
                    });

                }
            });
        }
    }   else    {
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Service unavailable!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        });
    }
}

- (void) onSetBackendCompleted:(NSString *) accessCode {
    NSArray* arr = [MPin listUsers];
    if (arr.count == 0) {
        [[ErrorHandler sharedManager] hideMessage];
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        id<IUser> user  = arr[0];
        if([user getState] == STARTED_REGISTRATION) {
            [[ErrorHandler sharedManager] hideMessage];
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        } else if([user getState] == REGISTERED )  {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                MpinStatus *mpinStatus = [MPin StartAuthentication:user accessCode:accessCode];
                dispatch_async(dispatch_get_main_queue(), ^ (void) {
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
