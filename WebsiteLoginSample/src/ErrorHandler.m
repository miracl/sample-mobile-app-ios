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


#import "ErrorHandler.h"
#import "MBProgressHUD.h"

@interface ErrorHandler()
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ErrorHandler

+ ( ErrorHandler * )sharedManager
{
    static ErrorHandler *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- ( instancetype )init
{
    self = [super init];
    if ( self )
    {
    }
    
    return self;
}

-( void ) stopLoading
{
    [self hideMessage];
}

- ( void ) updateMessage:( NSString * ) strMessage
    addActivityIndicator:( BOOL )addActivityIndicator
               hideAfter:( NSInteger ) hideAfter
{
    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void){
        if(!addActivityIndicator) {
            [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]].color = [UIColor clearColor];
        }
        self.hud.label.text = strMessage;
        if ( hideAfter > 0 )
        {
            [self performSelector:@selector( hideMessage ) withObject:nil afterDelay:hideAfter];
        }
    });
}

-( void ) presentMessageInViewController:( UIViewController * )viewController
                             errorString:( NSString * )strError
                    addActivityIndicator:( BOOL )addActivityIndicator
                             minShowTime:( NSInteger ) seconds
{
    
    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void) {
        [self hideMessage];
        self.hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        self.hud.label.text = strError;
        self.hud.minShowTime = seconds;
        
        UIColor *color;
        if(!addActivityIndicator) {
            color = [UIColor clearColor];
        } else {
            color = [UIColor darkGrayColor];
        }
        [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]].color = color;
    });
}

-( void ) hideMessage
{
    [self.hud hideAnimated:YES];
    self.hud = nil;
    NSLog(@"Hiding hud");
}

@end
