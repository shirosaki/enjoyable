#import "NSError+Description.h"

@implementation NSError (Description)

+ (NSError *)errorWithDomain:(NSString *)domain
                        code:(NSInteger)code
                 description:(NSString *)description {
    NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : description };
    return [NSError errorWithDomain:domain code:code userInfo:errorDict];

}

@end
