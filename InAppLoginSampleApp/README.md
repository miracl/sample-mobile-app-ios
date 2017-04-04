# sample-mobile-app-ios

In order to download and build the sample project you have to do the following steps:
1. Checkout the sample project from : https://github.com/miracl/sample-mobile-app-ios.git
>> git clone https://github.com/miracl/sample-mobile-app-ios.git
2. Open the sample app procject dir - checked out from previous command. Init recurent submodules. iOS sdk wrapper and MPIN core sdk
>> cd sample-mobile-app-ios/
>> git submodule init
>> cd incubator-milagro-mfa-sdk-ios/
>> git submodule init
>> cd ../
>> git submodule update --remote --recursive

After this steps you have to go to project dir and open the project file. Once the Xcode is loaded you should be able to build a project. 

In case you are interested from Sample application MFA flow you have to just checkout MFA branch from the same git working directori and repo. 
>> git branch 
    * master
    MFA
>> git checkout MFA
>> git pull origin MFA
