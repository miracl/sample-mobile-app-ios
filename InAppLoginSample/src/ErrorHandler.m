#import "ErrorHandler.h"
#import "ATMHud.h"

@interface CVXATMHud ( )

@end

@implementation CVXATMHud

- ( instancetype )init
{
    if ( ( self = [super init] ) )
    {}
    
    return self;
}

@end


@interface ErrorHandler ( ) {}

@end

@implementation ErrorHandler

+ ( ErrorHandler * )sharedManager
{
    static ErrorHandler *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- ( instancetype )init
{
    self = [super init];
    if ( self )
    {
        dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void){
            self.hud = [[CVXATMHud alloc] initWithDelegate:self];
        });
    }
    
    return self;
}

-( void ) startLoadingInController:( UIViewController * )viewController message:( NSString * )message
{
    [_hud setActivity:YES];
    [_hud setCaption:message];
    [_hud showInView:viewController.view];
}

-( void ) stopLoading
{
    [self hideMessage];
}

- ( void ) updateMessage:( NSString * ) strMessage
    addActivityIndicator:( BOOL )addActivityIndicator
               hideAfter:( NSInteger ) hideAfter
{
    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void){
        _hud.minShowTime = hideAfter;
        if ( addActivityIndicator )
        {
            [_hud setActivity:YES];
        }
        else
        {
            [_hud setActivity:NO];
        }
        [_hud setCaption:strMessage];
        [_hud update];
        if ( hideAfter > 0 )
        {
            [self performSelector:@selector( hideMessage ) withObject:nil afterDelay:hideAfter];
        }
    });
}

-( void ) presentMessageInViewController:( UIViewController * )viewController
                             errorString:( NSString * )strError
                    addActivityIndicator:( BOOL )addActivityIndicator
                             minShowTime:( NSInteger ) seconds
{
    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void){
        _hud.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height / 4);
        _hud.minShowTime = seconds;
        [_hud setCaption:strError];
        
        if ( addActivityIndicator )
        {
            [_hud setActivity:YES];
        }
        else
        {
            [_hud setActivity:NO];
        }
        
        [_hud showInView:viewController.view];
        
        if ( seconds > 0 )
        {
            [_hud hide];
        }
    });
}


-( void ) presentMessageInViewController:( UIViewController * )viewController
                             errorString:( NSString * )strError
                    addActivityIndicator:( BOOL )addActivityIndicator
                             minShowTime:( NSInteger ) seconds
                              atPosition: ( CGPoint ) point {
    
    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void){
        _hud.center = point;
        _hud.minShowTime = seconds;
        [_hud setCaption:strError];
        
        if ( addActivityIndicator )
        {
            [_hud setActivity:YES];
        }
        else
        {
            [_hud setActivity:NO];
        }
        
        [_hud showInView:viewController.view];
        
        if ( seconds > 0 )
        {
            [_hud hide];
        }
    });
}


-( void ) presentNoNetworkMessageInViewController:( UIViewController * )viewController
{
    dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^ (void){
        _hud.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height / 4);
        [_hud setActivity:NO];
        [_hud setImage:[UIImage imageNamed:@"CloudOffBar"]];
        [_hud showInView:viewController.view];
        [_hud setFixedSize:CGSizeMake(200, 100)];
        [_hud hide];
    });
}

-( void ) hideMessage
{
    [_hud hide];
    NSLog(@"Hiding hud");
}

@end
