//
//  NSMutableArray+MoveObject.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MoveObject)

- (void)moveObjectAtIndex:(NSUInteger)src toIndex:(NSUInteger)dst;
    // Move the object at index src to (post-move) index dst. Other
    // objects shift up or down as necessary to make room, as in
    // insertObject:atIndex:.

- (BOOL)moveFirstwards:(id)object upTo:(NSUInteger)minIndex;
- (BOOL)moveLastwards:(id)object upTo:(NSUInteger)maxIndex;
    // Move an object one step towards the first or last position in
    // the array, up to a minimum or maximum index. Returns YES if the
    // array changed; NO if the object was not in the array or was
    // already at the minimum/maximum index.

- (BOOL)moveFirstwards:(id)object;
- (BOOL)moveLastwards:(id)object;
    // Move an object towards the first or last position in the array.
    // Returns YES if the array changed; NO if the object was not in
    // the array or if the object was already in the first/last
    // position.


@end
