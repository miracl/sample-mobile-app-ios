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

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) NSString * accessCode;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceRegistered;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceStartedRegistration;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSpaceInfoView;

@property (weak, nonatomic) IBOutlet UILabel *lblIdentity;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblBackend;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerId;

@property (nonatomic, weak) IBOutlet UIButton *btnLogin;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnConfirm;
@property (nonatomic, weak) IBOutlet UIButton *btnResendEmail;
@property (nonatomic, weak) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteUnconfirmed;

@property (nonatomic, weak) IBOutlet UITextField *txtAddUser;
@property (nonatomic, weak) IBOutlet UIView *viewAddId;
@property (nonatomic, weak) IBOutlet UIView *viewStartedRegistration;
@property (weak, nonatomic) IBOutlet UIView  *viewInfo;
@property (weak, nonatomic) IBOutlet UIView  *viewRegistered;

@end
