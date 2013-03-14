//
//  NJInputPathElement.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#include "NJInputPathElement.h"

@implementation NJInputPathElement {
    NSString *_eid;
}

- (id)initWithName:(NSString *)name
               eid:(NSString *)eid
            parent:(NJInputPathElement *)parent {
    if ((self = [super init])) {
        self.name = name;
        self.parent = parent;
        _eid = eid;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJInputPathElement.class]
        && [[object uid] isEqualToString:self.uid];
}

- (NSUInteger)hash {
    return self.uid.hash;
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@~%@", _parent.uid, _eid];
}

- (NJInputPathElement *)elementForUID:(NSString *)uid {
    if ([uid isEqualToString:self.uid])
        return self;
    else if (![uid hasPrefix:self.uid])
        return nil;
    else {
        for (NJInputPathElement *elem in self.children) {
            NJInputPathElement *ret = [elem elementForUID:uid];
            if (ret)
                return ret;
        }
    }
    return nil;
}

@end
