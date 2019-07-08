#import "UIAlertController+MPinHelper.h"

@implementation UIAlertController (MPinHelper)

+(instancetype) infoAlertWithMessage:(NSString *)message
{
    UIAlertController *ac =[UIAlertController alertControllerWithTitle:message
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction
                   actionWithTitle:@"OK"
                   style:UIAlertActionStyleCancel
                   handler:nil]];
    return ac;
}


+(instancetype) errorAlertForMPinStatus:(MpinStatus *)mpinStatus
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"SDK Error"
                                                               message:[NSString stringWithFormat:@"Error message: %@",mpinStatus.errorMessage]
                                                        preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction
                   actionWithTitle:@"OK"
                   style:UIAlertActionStyleCancel
                   handler:nil]];
    return ac;
}


+(instancetype) enterPinAlertControllerForUserIdentity:(NSString *)userIdentity
                                      andSubmitHandler:(void (^)(NSString* enteredPin))submitHandler
{
    NSString *alertTitle = [NSString stringWithFormat:@"Please enter PIN code for \n %@ ", userIdentity];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"PIN Code";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Enter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *enteredPin = [alertController.textFields firstObject].text;
        submitHandler(enteredPin);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    return alertController;
}

+(instancetype) confirmPinAlertControllerForUserIdentity:(NSString *)userIdentity
                                              enteredPin:(NSString *)firstPin
                                        andSubmitHandler:(void (^)(bool))submitHandler
{
    NSString *alertTitle = [NSString stringWithFormat:@"Please confirm PIN code for \n %@ ", userIdentity];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"PIN Code";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Enter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *enteredPin = [alertController.textFields firstObject].text;
        submitHandler([enteredPin isEqualToString:firstPin]);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    return alertController;
}


@end
