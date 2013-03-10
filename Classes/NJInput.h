//
//  NJInput.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJInputPathElement.h"

@interface NJInput : NSObject <NJInputPathElement>

@property (nonatomic, assign) IOHIDElementCookie cookie;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, weak) id <NJInputPathElement> base;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) float magnitude;
@property (readonly) NSString *uid;

- (id)initWithName:(NSString *)newName base:(id <NJInputPathElement>)newBase;

- (void)notifyEvent:(IOHIDValueRef)value;
- (id)findSubInputForValue:(IOHIDValueRef)value;

@end
