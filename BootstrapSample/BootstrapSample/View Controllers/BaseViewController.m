#import "BaseViewController.h"
#import <MfaSdk/MPinMFA.h>
#import "UIAlertController+MPinHelper.h"

@implementation BaseViewController

#pragma mark - Public

-(void)showMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController infoAlertWithMessage:message];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    });
}

-(void)mPinOperationFailedWithStatus:(MpinStatus *)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Status: %@", status.errorMessage);
        UIAlertController *alertController = [UIAlertController errorAlertForMPinStatus:status];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    });
}

- (BOOL)isValidEmail:(NSString *)emailString
{
    if ([emailString length] == 0 || [emailString rangeOfString:@" "].location != NSNotFound ){
        return NO;
    }
    
    NSString *regExPattern = @"^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+$";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc]
                                  initWithPattern:regExPattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    NSUInteger regExMatches =
    [regEx numberOfMatchesInString:emailString
                           options:0
                             range:NSMakeRange(0, [emailString length])];
    
    return  (regExMatches != 0);
}


@end
