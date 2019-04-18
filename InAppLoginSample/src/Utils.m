#import "Utils.h"

@implementation Utils

+ ( BOOL )isValidEmail:( NSString * )emailString
{
    if ( [emailString length] == 0 ||
        [emailString rangeOfString:@" "].location != NSNotFound )
    {
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
    
    return  ( regExMatches != 0 );
}

@end
