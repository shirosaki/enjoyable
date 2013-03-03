//
//  NJInputAnalog.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NJInput.h"

@interface NJInputAnalog : NJInput

- (id)initWithIndex:(int)index rawMin:(long)rawMin rawMax:(long)rawMax;

@end
