#import <Foundation/Foundation.h>

@protocol NJInputPathElement <NSObject>

// TODO: It's time this became a real base class rather than a protocol.

- (NSArray *)children;
- (id <NJInputPathElement>) base;
- (NSString *)name;
- (NSString *)uid;

- (id <NJInputPathElement>)elementForUID:(NSString *)uid;

@end
