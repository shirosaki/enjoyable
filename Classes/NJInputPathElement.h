#import <Foundation/Foundation.h>

@protocol NJInputPathElement <NSObject>

- (NSArray *)children;
- (id <NJInputPathElement>) base;
- (NSString *)name;

@end
