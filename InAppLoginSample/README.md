# InAppLoginSampleApp

Sequence diagram of the In app login flow:
![InAppLoginFlow](Docs/InAppLogin.png)

In order to download and build the projects you have to do the following steps:
1. Checkout the sample project from : https://github.com/miracl/sample-mobile-app-ios.git
>> git clone https://github.com/miracl/sample-mobile-app-ios.git
2. Open the root dir from the checked out project. Navigate to folder InAppLoginSampleApp
>> pod install

After these steps you have to go to the desired project dir and open the .xcworkspace file. Please continue with the instructions on how to issue the needed credentials and configure the app so it can build and run.


### Create a demo web app to act as a backend service

Now that the project is imported, in order to enable you to test the demo iOS app, you should first of all create a demo MFA web app using one of our web SDKs, as explained in the [SDK Instructions](https://devdocs.trust.miracl.cloud/sdk-instructions/overview/) section of this documentation. The purpose of this is to have a running service which can authenticate all users who are registering with and logging into your iOS app (i.e. the web app will not be used for the purpose of in-browser login). Please note that, currently, only the [dotnet SDK](https://devdocs.trust.miracl.cloud/sdk-instructions/dotnet/) supports this functionality.

Once you have used the [authentication portal](https://trust.miracl.cloud/) to obtain a Client Id and Secret for your demo web app, you will need to configure the demo web app with these values, using the instructions provided on the web SDK page. It will then need to be hosted on an available url which means it is accessible by the iOS app. These steps are illustrated on the web SDK instructions page. A further note is that, if you are setting this up on a simple private network and using IIS Express to run the app which has been configured in Visual Studio, it will be necessary to make sure the firewall of the host machine allows incoming connections to the relevant port, and that the .vs/config/applicationhost.config file contains bindings which make it available:

`<bindings>
    <binding protocol="http" bindingInformation="*:5000:127.0.0.1" />
    <binding protocol="http" bindingInformation="*:5000:" />
</bindings>`

The `<binding protocol="http" bindingInformation="*:5000:" />` line will allow binding to any IP. Using, for example, `<binding protocol="http" bindingInformation="*:5000:192.168.1.18" />` would allow binding to a specific private IP only.

Note that here `http://192.168.1.18 ` is only being used as an example of a private IP. `ipconfig` or `ifconfig` should be used to determine the private IP of the host machine.

Note that, for the web app settings in the authentication portal you will need to make sure there is a redirect url which has the private IP of the host machine as its base:

![redirect-url-private-ip](Docs/redirect-url-private-ip.png)

Once the demo web app is running and hosted it will be available for the iOS app to connect to as the backend service to which your iOS app can authenticate.

### Configure the XCode project

Before building an iOS app, you will need to obtain your company id as the owner of the MFA web app. This is visible as a tooltip in the top right corner of your company dashboard in the portal:
![view-co-id](Docs/view-co-id.png)

While in XCode select the Config.m file and fill in the placeholders as follows:

`+(NSString*) clientId` replace with your company id.
`+(NSString*) backendDomain ` fill in the placeholder with the private IP/domain which you filled in during the previous step(for example `192.168.1.18`)
`+(int) backendPort` fill in the placeholder with the port for the private IP/domain
