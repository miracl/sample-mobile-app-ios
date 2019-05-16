#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@interface DvsRegistrationViewController : BaseViewController

@property (nonatomic, strong) id<IUser> currentUser;
+ (DvsRegistrationViewController*) instantiate;

@end
