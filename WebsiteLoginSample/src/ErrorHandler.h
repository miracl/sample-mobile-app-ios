#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ATMHud.h"

@interface CVXATMHud : ATMHud

@end

/// TODO :: WORNING :: Move error codes and description about MPIN Status to here

@interface ErrorHandler : NSObject

+ (ErrorHandler*)sharedManager;

- ( void ) presentNoNetworkMessageInViewController:( UIViewController * )viewController;

- ( void ) presentMessageInViewController:( UIViewController * )viewController
                             errorString:( NSString * )strError
                    addActivityIndicator:( BOOL )addActivityIndicator
                             minShowTime:( NSInteger ) seconds
                              atPosition: ( CGPoint ) point;

- ( void ) presentMessageInViewController:(UIViewController *)viewController
                              errorString:(NSString *)strMessage
                     addActivityIndicator:(BOOL)addActivityIndicator
                              minShowTime:(NSInteger) seconds;

- (void) updateMessage:(NSString *) strMessage   addActivityIndicator:(BOOL)addActivityIndicator hideAfter:(NSInteger) hideAfter;

-(void) hideMessage;

@property (nonatomic, strong) CVXATMHud *hud;


@end
