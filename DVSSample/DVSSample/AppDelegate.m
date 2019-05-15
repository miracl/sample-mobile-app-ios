#import "AppDelegate.h"
#import <MpinSdk/MPinMFA.h>
#import "Config.h"

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

@end
