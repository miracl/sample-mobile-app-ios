#import "AppDelegate.h"
#import "Config.h"
#import <MfaSdk/MPinMFA.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MPinMFA initSDK];
    [MPinMFA SetClientId:[Config companyId]];
    [MPinMFA SetBackend:[Config mfaURL]];

    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSFontAttributeName: [UIFont systemFontOfSize:14.0] }
                                             forState: UIControlStateNormal];

    
    return YES;
}

@end
