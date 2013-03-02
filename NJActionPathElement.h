#import <Foundation/Foundation.h>

@protocol NJActionPathElement <NSObject>

- (NSArray *)children;
- (id <NJActionPathElement>) base;
- (NSString *)name;

@end
