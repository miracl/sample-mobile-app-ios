#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface EnterPinViewController : BaseViewController <UITextFieldDelegate>

+ (EnterPinViewController*) instantiate: (NSString *) title;
@property (nonatomic) void (^pinCallback)(NSString*);
@property (nonatomic) void (^pinCancelCallback)(void);

@end
