#import "BaseViewController.h"

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) showMessage: (NSString*) message {
    [self execOnUiThread:^{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (void) execAsync:(dispatch_block_t) block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

- (void) execOnUiThread:(dispatch_block_t) block {
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
