#import "AppDelegate.h"
#import <MfaSdk/MPinMFA.h>
#import "Config.h"

@implementation AppDelegate

+ (AppDelegate *) delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MPinMFA initSDK];
    [MPinMFA SetClientId: [Config companyId]];
    return YES;
}

@end
