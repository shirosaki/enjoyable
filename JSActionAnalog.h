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

- (id)initWithIndex:(int)index rawMin:(long)rawMin rawMax:(long)rawMax;

@end
