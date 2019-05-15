#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>

@interface DvsRegistrationViewController : BaseViewController

+ (DvsRegistrationViewController*) instantiate;

@property (nonatomic, strong) id<IUser> currentUser;
@end
