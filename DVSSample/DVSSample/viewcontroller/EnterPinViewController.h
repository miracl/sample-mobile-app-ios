#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface EnterPinViewController : BaseViewController <UITextFieldDelegate>

+ (EnterPinViewController*) instantiate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) void (^pinCallback)(NSString*);
@property (nonatomic) void (^pinCancelCallback)(void);

@end
