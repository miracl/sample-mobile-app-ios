#define CORNER_RADIUS   14.0

#import "SuccessfulViewController.h"
#import "PinPadViewController.h"

@interface SuccessfulViewController ()

@property (nonatomic, weak) IBOutlet UIButton       *btnLogin;
- ( NSInteger ) findControllerIndexInNavHeirarchy:(Class) clazz;

- (IBAction)onClickLoginButton:(id)sender;

@end

@implementation SuccessfulViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnLogin.layer.cornerRadius  =   CORNER_RADIUS;
}

- ( NSInteger ) findControllerIndexInNavHeirarchy:(Class) clazz {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++)
        if ( [self.navigationController.viewControllers[i] isMemberOfClass:clazz])
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
