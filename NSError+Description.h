#import <Foundation/Foundation.h>

@interface NSError (Description)

+ (NSError *)errorWithDomain:(NSString *)domain
                        code:(NSInteger)code
                 description:(NSString *)description;

@end
