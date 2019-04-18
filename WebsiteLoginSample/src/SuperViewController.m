#import "SuperViewController.h"

@interface SuperViewController ()
- (IBAction)back:(id)sender;
@end

@implementation SuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * newBackButton = [[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:@"arrowLeft"]  style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
