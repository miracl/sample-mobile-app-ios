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

#import "SuccessfulViewController.h"
#import "PinPadViewController.h"

@interface SuccessfulViewController ()

@property (nonatomic, weak) IBOutlet UIButton       *btnLogin;
- ( NSInteger ) findControllerIndexInNavHeirarchy:(Class) clazz;

- (IBAction)onClickLoginButton:(id)sender;

@end

@implementation SuccessfulViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnLogin.layer.cornerRadius  =   CORNER_RADIUS;
}

- ( NSInteger ) findControllerIndexInNavHeirarchy:(Class) clazz {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++)
        if ( [self.navigationController.viewControllers[i] isMemberOfClass:clazz])
            return i;
    return -1;
}

- (IBAction)onClickLoginButton:(id)sender {
    NSInteger i  = [self findControllerIndexInNavHeirarchy:[PinPadViewController class]];
    if(i == -1) {
        UIViewController *_vcConcent = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
        [self.navigationController pushViewController:_vcConcent animated:YES];
    } else {
        [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
    }
}

@end
