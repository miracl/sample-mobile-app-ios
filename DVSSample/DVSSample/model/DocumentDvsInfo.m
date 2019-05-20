#import "DocumentDvsInfo.h"

@implementation DocumentDvsInfo

- (NSString*) serializeDocumentDvsInfo:(DocumentDvsInfo *) info {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:info.authToken forKey:@"authToken"];
    [dict setObject:info.hashValue forKey:@"hash"];
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
    
    if (!dataBuffer) {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [input length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
