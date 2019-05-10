#import "AppDelegate.h"
#import <MpinSdk/MPinMFA.h>
#import "Config.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize currentUser = _currentUser;

+ (AppDelegate *) delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MPinMFA initSDK];
    [MPinMFA SetClientId: [Config companyId]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
