#import "UsersTableViewController.h"
#import <MfaSdk/MPinMFA.h>

@interface UsersTableViewController ()

@property (nonatomic,strong) NSArray *users;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation UsersTableViewController

#pragma mark - View Controller lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
   
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlUpdated:)
                  forControlEvents:UIControlEventValueChanged];
    self.users = [self userIdentities];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if(!self.userSelectionMode){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.users = [self userIdentities];
    [self.tableView reloadData];
}

#pragma mark - Actions
- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    
    if(!self.userSelectionMode){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }  else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    id<IUser> user = self.users[indexPath.row];
    cell.textLabel.text = [user getIdentity];
    cell.detailTextLabel.text = [self userStateAsString:user];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.userSelectionMode){
        self.selectedUser = self.users[indexPath.row];
        [self performSegueWithIdentifier:@"selectRegisteredUserUnwindsegue" sender:nil];
    }
}

#pragma mark - UITableViewDelegate
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.userSelectionMode){
        UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[]];
        return configuration;
    }
    
    
    id<IUser> userForDelete = self.users[indexPath.row];
    UIContextualAction *deleteAction =
    [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                            title:@"Delete"
                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                                              
                                              UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Do you want to delete this user?" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                              UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                                  [MPinMFA DeleteUser:userForDelete];
                                                  completionHandler(YES);
                                              }];
                                              UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler(NO);
                                              }];
                                              
                                              [controller addAction:yesAction];
                                              [controller addAction:noAction];
                                              
                                              [self presentViewController:controller animated:YES completion:nil];
                                          }];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    return configuration;
}

#pragma mark - Private
-(void)refreshControlUpdated:(id)sender
{
    self.users = [self userIdentities];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSArray *)userIdentities
{
    if(!self.userSelectionMode){
        return [MPinMFA listUsers];
    }
    
    NSPredicate *registeredUsersPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if([evaluatedObject conformsToProtocol:@protocol(IUser)]){
            id<IUser> user = (id<IUser>) evaluatedObject;
            return [user getState] == REGISTERED;
        }
        
        return NO;
    }];
    
    return [[MPinMFA listUsers] filteredArrayUsingPredicate:registeredUsersPredicate];
}


-(NSString *)userStateAsString:(id<IUser>)user
{
    NSString *userStateAsString;
    switch ([user getState])
    {
        case INVALID:
            userStateAsString = @"INVALID";
            break;
        case REGISTERED:
            userStateAsString = @"REGISTERED";
            break;
        case BLOCKED:
            userStateAsString = @"BLOCKED";
            break;
        case STARTED_REGISTRATION:
            userStateAsString = @"STARTED_REGISTRATION";
            break;
        default:
            userStateAsString = @"INVALID";
            break;
    }
    return userStateAsString;
}

@end
