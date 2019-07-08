* **category**: Samples
* **copyright**: 2019 MIRACL Technologies LTD
* **link**: https://github.com/miracl/sample-mobile-app-ios

# sample-mobile-app-ios

This repository contains sample applications for the following flows:
##### Mobile App Login - located in folder [MobileAppLoginSample](MobileAppLoginSample/README.md)
This flow is used to login into the mobile app itself.

##### Website login - located in folder [WebsiteLoginSample](WebsiteLoginSample/README.md)
This flow is used to log into another app using the mobile app (the oidc flow).

##### DVSSample - located in folder [DVSSample](DVSSample/README.md)
This flow is used to sign documents.

##### BootstrapSample - located in folder [BootstrapSample](BootstrapSample/README.md)
Bootstrap codes are used to skip the customer verification when the user have already registered identity on another device. There are two flows:
1. Bootstrap Code Registration - use an already generated bootstrap code from another device to transfer an identity to the device skipping the registration verification process
2. Bootstrap Code Generation - generate a bootstrap code for a registered identity that could be used to transfer it to another device

All samples use [MpinSdk.framework](https://github.com/miracl/mfa-client-sdk-ios) which is available via [Cocoapods](https://cocoapods.org/).

Instructions on how to build and run each sample can be found in the README located in the folder for each sample.
