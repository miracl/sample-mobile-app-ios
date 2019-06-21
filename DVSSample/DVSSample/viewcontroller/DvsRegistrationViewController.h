#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import <MfaSdk/MPinMFA.h>
#import <MfaSdk/IUser.h>

@interface DvsRegistrationViewController : BaseViewController

@property (nonatomic, strong) id<IUser> currentUser;
+ (DvsRegistrationViewController*) instantiate;

@end
