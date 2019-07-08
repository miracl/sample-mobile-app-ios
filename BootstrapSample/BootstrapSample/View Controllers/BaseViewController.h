#import <UIKit/UIKit.h>
#import <MfaSdk/MPinMFA.h>

@interface BaseViewController : UIViewController

- (void)showMessage:(NSString *)message;
- (void)mPinOperationFailedWithStatus:(MpinStatus *)status;
- (BOOL)isValidEmail:(NSString *)emailString;

@end
