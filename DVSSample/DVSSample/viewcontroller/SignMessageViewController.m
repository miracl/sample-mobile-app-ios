#import "SignMessageViewController.h"
#import "AccessCodeServiceApi.h"
#import <MpinSdk/MPinMFA.h>
#import <MpinSdk/IUser.h>
#import "AppDelegate.h"
#import "EnterPinViewController.h"

@interface SignMessageViewController ()
@property (nonatomic, strong) AppDelegate* appDelegate;
@end

@implementation SignMessageViewController
@synthesize appDelegate = _appDelegate;

+ (SignMessageViewController*) instantiate {
    return [[UIStoryboard storyboardWithName: @"Main" bundle:nil] instantiateViewControllerWithIdentifier: @"SignMessageViewController"];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = [AppDelegate delegate];
    NSString *email = [self.currentUser getIdentity];
    self.titleLabel.text = [NSString stringWithFormat: @"An identity %@ has been registered for DVS. Now you can sign documents with it.", email];
    self.textField.delegate = self;
    [self.btnSign addTarget:self action:@selector(onSignClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void) onSignClick {
    [self.textField resignFirstResponder];
    __weak EnterPinViewController *enterPinController = [EnterPinViewController instantiate];
    enterPinController.pinCallback = ^(NSString *pin) {
        [enterPinController dismissViewControllerAnimated:YES completion:^{
            [self onPinEntered:pin];
        }];
    };
    [self presentViewController:enterPinController animated:YES completion:nil];
}

- (void) onPinEntered:(NSString*) pin {
    NSString *message = self.textField.text;
    [self createDocumentHash:pin message:message];
}

- (void) createDocumentHash:(NSString*) pin message:(NSString*) message {
    AccessCodeServiceApi *api = [[AccessCodeServiceApi alloc] init];
    [api createDocumentHash:message withCallback:^(NSError *error, DocumentDvsInfo *info) {
        if(error) {
            [self showMessage: error.localizedDescription];
        } else {
            id<IUser> user = self.appDelegate.currentUser;
            double time = (double)info.timestamp;
            BridgeSignature *bridgeSignature = nil;
            MpinStatus *status = [MPinMFA Sign:user documentHash:[info.hash dataUsingEncoding:NSUTF8StringEncoding] pin0:pin pin1:nil epochTime:time result:&bridgeSignature];
            if(status.status == OK) {
                [self verifySignature:bridgeSignature documentDvsInfo:info];
            }
        }
    }];
}

- (void) verifySignature:(BridgeSignature *) signature documentDvsInfo:(DocumentDvsInfo*) info {
    NSString *verificationData = [self serializeSignature:signature];
    NSString *documentData = [self serializeDocumentDvsInfo:info];
    AccessCodeServiceApi *api = [[AccessCodeServiceApi alloc] init];
    [api verifySignature:verificationData documentData:documentData withCallback:^(NSString *result, NSError *error) {
        if(error) {
            [self showMessage: error.localizedDescription];
        } else {
            [self showMessage: result];
        }
    }];
}

- (NSString*) serializeDocumentDvsInfo:(DocumentDvsInfo *) info {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:info.authToken forKey:@"authToken"];
    [dict setObject:info.hash forKey:@"hash"];
    [dict setObject:[NSString stringWithFormat:@"%lu", info.timestamp] forKey:@"timestamp"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return @"";
}

- (NSString*) serializeSignature:(BridgeSignature*) signature {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:signature.strDtas forKey:@"dtas"];
    [dict setObject:signature.strMpinId forKey:@"mpinId"];
    [dict setObject:[self hexadecimalString:signature.strHash] forKey:@"hash"];
    [dict setObject:[self hexadecimalString:signature.strPublicKey] forKey:@"publicKey"];
    [dict setObject:[self hexadecimalString:signature.strU] forKey:@"u"];
    [dict setObject:[self hexadecimalString:signature.strV] forKey:@"v"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return @"";
}

- (NSString *)hexadecimalString:(NSData *) input {
    
    const unsigned char *dataBuffer = (const unsigned char *)[input bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [input length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

// UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
