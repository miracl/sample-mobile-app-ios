# sample-mobile-app-ios

In order to download and build the projects you have to do the following steps:
1. Checkout the sample project from : https://github.com/miracl/sample-mobile-app-ios.git
>> git clone https://github.com/miracl/sample-mobile-app-ios.git
2. Open the root dir from the checked out project. Init recurent submodules. iOS sdk wrapper and MPIN core sdk
>> cd sample-mobile-app-ios/
>> git submodule init
>> git submodule update
>> cd incubator-milagro-mfa-sdk-ios/
>> git submodule init
>> git submodule update
>> cd ../

After this steps you have to go to the desired project dir and open the workspace file. Once the Xcode is loaded you should be able to build a project.
