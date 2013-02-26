//
//  JSActionAnalog.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JSAction.h"

@interface JSActionAnalog : JSAction

@property (assign) float offset;
@property (assign) float scale;

- (id)initWithIndex:(int)newIndex offset:(float)offset scale:(float)scale;
- (float)getRealValue:(int)value;

@end
