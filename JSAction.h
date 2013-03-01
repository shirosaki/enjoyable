//
//  JSAction.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@interface JSAction : NSObject

@property (nonatomic, assign) IOHIDElementCookie cookie;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, weak) id base;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, readonly) float magnitude;
@property (readonly) NSString *uid;

- (id)initWithName:(NSString *)newName base:(JSAction *)newBase;

- (void)notifyEvent:(IOHIDValueRef)value;
- (id)findSubActionForValue:(IOHIDValueRef)value;

@end
