#import <UIKit/UIKit.h>
#import <MfaSdk/IUser.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *accessCode;
@property (nonatomic, strong) id<IUser> currentUser;

+ (AppDelegate *) delegate;

@end

