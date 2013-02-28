//
//  JSAction.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@interface JSAction : NSObject

@property (assign) void *cookie;
@property (copy) NSArray *children;
@property (weak) id base;
@property (copy) NSString *name;
@property (assign) BOOL active;
@property (readonly) float magnitude;
@property (readonly) NSString *uid;

- (id)initWithName:(NSString *)newName base:(JSAction *)newBase;

- (void)notifyEvent:(IOHIDValueRef)value;
- (id)findSubActionForValue:(IOHIDValueRef)value;

@end
