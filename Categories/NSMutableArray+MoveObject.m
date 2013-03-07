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
    [self insertObject:obj atIndex:dst > src ? dst - 1 : dst];
}

@end
