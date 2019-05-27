# Mobile App Login Sample

* **category**: Samples
* **copyright**: 2019 Miracl Technologies LTD
* **link**: https://github.com/miracl/sample-mobile-app-ios/tree/master/MobileAppLoginSample

## Description

This sample demonstrates how to use the [MIRACL iOS SDK](https://github.com/miracl/mfa-client-sdk-ios) in order to login into the mobile app itself using [MIRACL MFA Platform](https://trust.miracl.cloud) authentication via an iOS device. This is the so-called **Mobile App Login** and here is the methods sequence you need to achieve it:

<img src="https://raw.githubusercontent.com/miracl/mfa-client-sdk-ios/master/docs/MobileAppLogin_short.png" width="700">

## Requirements

* iOS 12 or higher
* Cocoapods

## Setup

1. Checkout the sample project from : https://github.com/miracl/sample-mobile-app-ios.git
>> git clone https://github.com/miracl/sample-mobile-app-ios.git
2. [Run a backend application](#create-a-demo-web-app-to-act-as-a-backend-service)
3. [Configure the app with the issued credentials](#configure-the-app-with-the-issued-credentials)
4. Build the project:
	1. From command line open the root dir from the checked out project. Navigate to folder MobileAppLoginSample.
	2. Execute the following command:
	>> pod install
	3. Open the .xcworkspace file which is located in the current directory.

## Create a demo web app to act as a backend service

In order to be able to test the demo iOS app, you need to run a backend service as a relying party demo web app (RPA). You could use one of our web SDKs as explained in the [SDK Instructions](https://devdocs.trust.miracl.cloud/sdk-instructions/) of our documentation.
The SDK authenticates to the [MIRACL Trust authentication portal](https://trust.miracl.cloud/), called also MFA, using [OpenIDConnect](https://openid.net/connect/) protocol. This means you need to login and create an application in it so you can take credentials (`client id` and `client secret`) for the communication. Note that the redirect url set in this MFA web application needs to match your demo backend application, concatenated with `/login` by default.

Once you have run the demo web app you need to host it on a visible uri for the mobile app. These steps are documented in details in the
[dotnet SDK](https://devdocs.trust.miracl.cloud/sdk-instructions/dotnet/) which supports this functionality. Just reassure that the proper redirect uri (constructed as `demoAppUri/login`) is added as a redirect uri to the [authentication portal](https://trust.miracl.cloud/) application settings you're running the web app with:

<img src="images/redirect-url-private-ip.png" width="400">

## Configure the app with the issued credentials

Before building the iOS app, you need to configure it. In Xcode, open the [`Config.m`](MobileAppLoginSample/Config.m) file and fill in the placeholders as follows:

```
+ (NSString *)companyId
{
  return <# Replace with your company id #>;
}

+ (NSString *)backendDomain
{
  return <#Replace with backend ip/domain#>;
}

+ (int)backendPort
{
  return <#Replace with backend ip/domain port#>;
}

+ (NSString *)httpScheme
{
  return <# Replace with backend http scheme #>;
}
```

As the owner of the MFA web app, your `Company ID` is visible as a tooltip in the top right corner of your company dashboard in the MFA portal:

<img src="images/view-co-id.png" width="400">

Note that `authBackend` should always be https://api.mpin.io in order to authenticate against [MIRACL Trust authentication portal](https://trust.miracl.cloud/).

`backendDomain`, `backendPort` and `httpScheme` are parts from the url of your demo RPA [configured here](#create-a-demo-web-app-to-act-as-a-backend-service).

## Mobile App Login flow implementation by MIRACL iOS SDK

### RegisterViewController

Initial user registration process is managed in the [RegisterViewController.m](src/RegisterViewController.m). Initially when the screen is displayed several SDK methods are executed within the `viewDidLoad` method. First the SDK is initialized through the [`[MPinMFA initSDK]`](https://github.com/miracl/mfa-client-sdk-ios#void-initsdk) method. Then the SDK needs to be setup with the Authentication Server by the Company ID (using [`[MPinMFA SetClientId:]`](https://github.com/miracl/mfa-client-sdk-ios#void-setclientid-nsstring-clientid)). For improved security [`[MPinMFA AddTrustedDomain:]`](https://github.com/miracl/mfa-client-sdk-ios#void-addtrusteddomain-nsstring--domain) is also called:

```
[MPinMFA initSDK];
[MPinMFA SetClientId:[Config companyId]];
NSArray *domains = [Config trustedDomains];
for (NSString *domain in domains) {
  [MPinMFA AddTrustedDomain: domain];
}
```

Note: Since most of the Miracl iOS SDK methods can be time-consuming operations, it is recommended to be called on background queue with NSOperationQueue or Grand Central Dispatch. You could see this pattern through the sample application.

Then in `viewWillAppear` the authentication API uri is set (using [`[MPinMFA SetBackend:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-setbackend-const-nsstring-url)):

```
MpinStatus *mpinStatus = [MPinMFA SetBackend: [Config authBackend]];
```

If `mpinStatus.status` has value `OK` the next step is to obtain `access code`. This is done in the `getAccessCode` method where an `HTTP POST` request is made to the endpoint defined in `[Config authzUrl]`. This request returns `JSON` as a response from where we get the `authorizeURL`:

```
jsonObject[@"authorizeURL"]
```

This `authorizeURL` is used to obtain the `access code` through [`[MPinMFA GetAccessCode: accessCode:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-getaccesscode-nsstring-authzurl-accesscode-nsstring-accesscode):

```
MpinStatus *mpinStatus = [MPinMFA GetAccessCode:jsonObject[@"authorizeURL"] accessCode:&strAccessCode];
```

If `mpinStatus.status` has value `OK` this means that the `access code` has been successfully obtained.

In `viewWillAppear` an SDK call to [`[MPinMFA listUsers]`](https://github.com/miracl/mfa-client-sdk-ios#nsmutablearray-listusers) is made and if it returns more than one user then all of users need to be deleted as the demo is designed to work with one user. This means that the [`[MPinMFA DeleteUser:]`](https://github.com/miracl/mfa-client-sdk-ios#void-deleteuser-const-idiuser-user) method will be called to remove all users:

```
if (arrUsers.count > 1) {
  for (int i = 0; i < arrUsers.count; i++) {
    [MPinMFA DeleteUser:arrUsers[i]];
  }
  [self setupAddId];
}
```

If there is one user then it is important to check the value of `[self.user getState]`. 
If it is `INVALID` or `BLOCKED` ([see all user state values](https://github.com/miracl/mfa-client-sdk-ios#idiuser-makenewuser-const-nsstring-identity-devicename-const-nsstring-devname)) then the user is deleted with SDK call to [`[MPinMFA DeleteUser:]`](https://github.com/miracl/mfa-client-sdk-ios#void-deleteuser-const-idiuser-user).

### Identity Registration

To start the registration the user is first asked to enter their email: 

<img src="images/reg_screen_email.png" width="400">

Once the user fills in their email and presses `Submit` the following code is executed:

```
self.user = [MPinMFA MakeNewUser:strUserName deviceName:@"SampleDevName"];
MpinStatus *mpinStatus = [MPinMFA StartRegistration:self.user accessCode:self.accessCode pmi:@""];
```

[`[MPinMFA MakeNewUser: deviceName:]`](https://github.com/miracl/mfa-client-sdk-ios#idiuser-makenewuser-const-nsstring-identity-devicename-const-nsstring-devname) creates a new user and [`[MPinMFA StartRegistration: accessCode: pmi:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-startregistration-const-idiuser-user-accesscode-nsstring-accesscode-pmi-nsstring-pmi) starts the registration process for that new user. 

Note that, for demonstration purposes, the `deviceName` variable is statically set here but it could be determined by user's requirements.

If `mpinStatus.status` has a value `OK` this means that the registration was started successfully. The user is then presented with a UI to confirm the registration:

<img src="images/reg_confirm.png" width="400">

If the registration was started successfully, a confirmation message is sent to the user's email in order to verify their identity registration. After the email verification, they need to click the `Confirmed` button. 
The user also has options to select `Delete` or `Resend Email`. Pressing `Delete` will result in SDK call to [`[MPinMFA DeleteUser:]`](https://github.com/miracl/mfa-client-sdk-ios#void-deleteuser-const-idiuser-user) and the flow will need to start over sending the user back to the [first screen](https://github.com/avlaev/sample-mobile-app-ios/tree/mobile_login_sample_docs/MobileAppLoginSample#mobile-app-login-flow-implementation-by-miracl-ios-sdk).
Pressing `Resend Email` will delete the currently created user and create a new user object with the same `identity`.
Consecutively [`[self.user getIdentity]`](https://github.com/miracl/mfa-client-sdk-ios#idiuser-makenewuser-const-nsstring-identity-devicename-const-nsstring-devname) will be called and the result will be kept as a temporary reference to the user's `identity` as that user is about to be deleted. After that [`[MPinMFA DeleteUser:]`](https://github.com/miracl/mfa-client-sdk-ios#void-deleteuser-const-idiuser-user) is called to delete the user. This is followed by a SDK call to [`[MPinMFA MakeNewUser: deviceName:]`](https://github.com/miracl/mfa-client-sdk-ios#idiuser-makenewuser-const-nsstring-identity-devicename-const-nsstring-devname) where the saved `identity` is passed as 
first parameter. Finally [`[MPinMFA StartRegistration: accessCode: pmi:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-startregistration-const-idiuser-user-accesscode-nsstring-accesscode-pmi-nsstring-pmi) SDK call is made which triggers a new confirmation message to be sent to the user's email:

```
NSString *strUserID = [self.user getIdentity];
[MPinMFA DeleteUser:self.user];
self.user = [MPinMFA MakeNewUser:strUserID deviceName:@"SampleDevName"];
MpinStatus *mpinStatus = [MPinMFA StartRegistration:self.user accessCode:self.accessCode pmi:@""];
```

Once the user presses the `Confirmed` button, a SDK call to [`[MPinMFA ConfirmRegistration:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-confirmregistration-const-idiuser-user) is made:

```
MpinStatus *mpinStatus = [MPinMFA ConfirmRegistration:self.user];
```

If `mpinStatus.status` has value `OK` then the operation is successful and the user is presented with a [`PinPadViewController.m`](src/PinPadViewController.m) to create their PIN (see more about `PinPadViewController` [here](#PinPadViewController)):

<img src="images/enter_pin.png" width="400">

When the user enter their `PIN` number and presses `Send`, the `onClickSendButton` method is called where [`[MPinMFA FinishRegistration: pin0: pin1:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-finishregistration-const-idiuser-user-pin0-nsstring-pin0-pin1-nsstring-pin1) is called:

```
MpinStatus *mpinStatus = [MPinMFA FinishRegistration:self.user pin0:strPIN pin1:nil];
```

If `mpinStatus.status` has value `OK` then the registration is finished and the user is presented with [`SuccessfulViewController.m`](src/SuccessfulViewController.m):

<img src="images/reg_sucess_vc.png" width="400">

Pressing the `Login` button will send the user to the previous screen where they need to press the back navigation button (located in the top left part of the screen) again to return the [RegisterViewController.m](src/RegisterViewController.m). This time `RegisterViewController` will find the registered user within the `viewWillAppear` method and display the information for that user. Relevant information for the registered user is obtained by its `getState`, `getBackend`, `getIdentity` and `getCustomerId` [methods](https://github.com/miracl/mfa-client-sdk-ios#idiuser-makenewuser-const-nsstring-identity-devicename-const-nsstring-devname):

```
self.user = arrUsers[0];
switch ([self.user getState]) {
  ...
  case REGISTERED:
    [self setupRegistered];
  ... 
```

The user will see the following UI:

<img src="images/reg_user_available.png" width="400">

If the user decides to press the `Delete` button this will result in a call to [`[MPinMFA DeleteUser:]`](https://github.com/miracl/mfa-client-sdk-ios#void-deleteuser-const-idiuser-user) and the flow will need to start over as there will be no registered user to log in with.

### Identity Authentication

If the user presses the `Login` button then the authentication process will begin for that user:

```
- (IBAction)login:(id)sender
{
  [self startAuthentication];
}
``` 

Within the `startAuthentication` method first [`[MPinMFA StartAuthentication: accessCode:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-startauthentication-const-idiuser-user-accesscode-nsstring-accesscode) is called:

```
MpinStatus *mpinStatus = [MPinMFA StartAuthentication:self.user accessCode:self.accessCode];
```

If `mpinStatus.status` has value `OK` the user will be presented with [`PinPadViewController`](#PinPadViewController) to enter their `PIN` number. After entering the `PIN` number and pressing `Send` the `- (IBAction)onClickSendButton:(id)sender` method of [`PinPadViewController.m`](src/PinPadViewController.m) is called which will now detect that a PIN is being entered for a registered user (the value of `[self.user getState]` needs to have value of `REGISTERED`) which will result in a call to [`[MPinMFA FinishAuthentication: pin: pin1:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-finishauthentication-const-idiuser-user-pin-nsstring-pin-pin1-nsstring-pin1-accesscode-nsstring-accesscode-authzcode-nsstring-authzcode)

```
MpinStatus *mpinStatus = [MPinMFA FinishAuthentication:self.user pin:strPIN pin1:nil accessCode:self.accessCode authzCode:&strAuthzCode];
```

If `mpinStatus.status` has value `OK` the `strAuthzCode` will contain a non-empty authorization code. The next step is to use that `strAuthzCode` to make an `HTTP POST` request to the url defined in `[Config authCheckUrl]`. If the `HTTP Status` code in the response is `200` this means that the login is successful which also marks the end of the flow and the user will be presented with a popup message to indicate that:

<img src="images/login_success.png" width="400">

Pressing `Start over` will send the user back so they can log in again with the same user.

It is worth mentioning that [RegisterViewController.m](src/RegisterViewController.m) executes multiple roles within the demo. It shows the registration UI if there are no users. It will also show the appropriate UI in order to confirm a started registration. And finally, it will show the information for an existing registered user allowing login for that user.

### PinPadViewController

The purpose of this view controller is to collect a `PIN` number from the user and handle it.
First, within the `viewWillAppear` method, the current user is loaded with a call to [`[MPinMFA listUsers]`](https://github.com/miracl/mfa-client-sdk-ios#nsmutablearray-listusers):

```
self.user = [MPinMFA listUsers][0];
```

[`PinPadViewController.m`](src/PinPadViewController.m) has different behavior when handling the entered `PIN` depending on the user state `[self.user getState]`.
Once the user enters a `PIN` number `onClickSendButton` is called where depending on the value of `[self.user getState]` different operations are performed. If the state is `STARTED_REGISTRATION` the app will try to finish the registration with a call to [`[MPinMFA FinishRegistration: pin0: pin1:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-finishregistration-const-idiuser-user-pin0-nsstring-pin0-pin1-nsstring-pin1). If the state is `REGISTERED`
the app will try to finish authentication with a call to [`[MPinMFA FinishAuthentication: pin: pin1:]`](https://github.com/miracl/mfa-client-sdk-ios#mpinstatus-finishauthentication-const-idiuser-user-pin-nsstring-pin-pin1-nsstring-pin1-accesscode-nsstring-accesscode-authzcode-nsstring-authzcode). If the state is `BLOCKED` an error message will be displayed.

## See also

* [DvsSample](https://github.com/miracl/sample-mobile-app-ios/tree/master/DVSSample)
* [WebsiteLoginSample](https://github.com/miracl/sample-mobile-app-ios/tree/master/WebsiteLoginSample)