#import <UIKit/UIKit.h>
#import <MfaSdk/IUser.h>

@interface UsersTableViewController : UITableViewController

@property (nonatomic) BOOL userSelectionMode;
@property (nonatomic) id<IUser> selectedUser;

@end
