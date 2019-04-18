#import "SuccessfulViewController.h"
#import "PinPadViewController.h"

@interface SuccessfulViewController ()

@property (nonatomic, weak) IBOutlet UIButton       *btnLogin;
- ( NSInteger ) findControllerIndexInNavHeirarchy:(Class) class;

- (IBAction)onClickLoginButton:(id)sender;

@end

@implementation SuccessfulViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- ( NSInteger ) findControllerIndexInNavHeirarchy:(Class) class {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++)
        if ( [self.navigationController.viewControllers[i] isMemberOfClass:class])
            return i;
    return -1;
}

- (IBAction)onClickLoginButton:(id)sender {
    NSInteger i  = [self findControllerIndexInNavHeirarchy:[PinPadViewController class]];
    if(i == -1) {
        UIViewController *_vcConcent = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PinPadViewController"];
        [self.navigationController pushViewController:_vcConcent animated:YES];
    } else {
        [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
    }
}

@end
