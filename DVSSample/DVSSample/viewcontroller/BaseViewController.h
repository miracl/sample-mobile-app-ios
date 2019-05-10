#import <UIKit/UIKit.h>

@interface BaseViewController: UIViewController

- (void) showMessage: (NSString*) message;
- (void) execAsync:(dispatch_block_t) block;
- (void) execOnUiThread:(dispatch_block_t) block;
- (void) refreshAccessCode;

@end
