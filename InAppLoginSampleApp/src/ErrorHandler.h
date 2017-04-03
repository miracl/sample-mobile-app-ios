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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATMHud.h"

@interface CVXATMHud : ATMHud

@end

/// TODO :: WORNING :: Move error codes and description about MPIN Status to here

@interface ErrorHandler : NSObject

+ (ErrorHandler*)sharedManager;

- ( void ) presentNoNetworkMessageInViewController:( UIViewController * )viewController;

- ( void ) presentMessageInViewController:( UIViewController * )viewController
                             errorString:( NSString * )strError
                    addActivityIndicator:( BOOL )addActivityIndicator
                             minShowTime:( NSInteger ) seconds
                              atPosition: ( CGPoint ) point;

- ( void ) presentMessageInViewController:(UIViewController *)viewController
                              errorString:(NSString *)strMessage
                     addActivityIndicator:(BOOL)addActivityIndicator
                              minShowTime:(NSInteger) seconds;

- (void) updateMessage:(NSString *) strMessage   addActivityIndicator:(BOOL)addActivityIndicator hideAfter:(NSInteger) hideAfter;

-(void) hideMessage;

@property (nonatomic, strong) CVXATMHud *hud;


@end
