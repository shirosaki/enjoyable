//
//  NJInputPathElement.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//
@interface NJInputPathElement : NSObject

- (id)initWithName:(NSString *)name
               eid:(NSString *)eid
            parent:(NJInputPathElement *)parent;

@property (nonatomic, weak) NJInputPathElement *parent;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSString *uid;
@property (nonatomic, strong) NSArray *children;

- (NJInputPathElement *)elementForUID:(NSString *)uid;

@end
