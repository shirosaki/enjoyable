//
//  NJInputPathElement.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//
@interface NJInputPathElement : NSObject

- (id)initWithName:(NSString *)name
               did:(NSString *)did
              base:(NJInputPathElement *)base;

@property (nonatomic, weak) NJInputPathElement *base;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSString *uid;
@property (nonatomic, strong) NSArray *children;

- (NJInputPathElement *)elementForUID:(NSString *)uid;

@end
