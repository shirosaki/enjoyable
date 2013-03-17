//
//  NSMutableArray+MoveObject.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import "NSMutableArray+MoveObject.h"

@implementation NSMutableArray (MoveObject)

- (void)moveObjectAtIndex:(NSUInteger)src toIndex:(NSUInteger)dst {
    id obj = self[src];
    [self removeObjectAtIndex:src];
    [self insertObject:obj atIndex:dst];
}

- (BOOL)moveFirstwards:(id)object upTo:(NSUInteger)minIndex {
    NSUInteger idx = [self indexOfObject:object];
    if (idx > minIndex && idx != NSNotFound) {
        [self exchangeObjectAtIndex:idx withObjectAtIndex:idx - 1];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)moveLastwards:(id)object upTo:(NSUInteger)maxIndex {
    maxIndex = MIN(self.count - 1, maxIndex);
    NSUInteger idx = [self indexOfObject:object];
    if (idx < maxIndex && idx != NSNotFound) {
        [self exchangeObjectAtIndex:idx withObjectAtIndex:idx + 1];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)moveFirstwards:(id)object {
    return [self moveFirstwards:object upTo:0];
}

- (BOOL)moveLastwards:(id)object {
    return [self moveLastwards:object upTo:NSNotFound];
}


@end
