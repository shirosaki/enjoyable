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

@end
