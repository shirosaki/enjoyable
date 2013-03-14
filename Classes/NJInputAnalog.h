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

- (id)initWithElement:(IOHIDElementRef)element
                index:(int)index
               parent:(NJInputPathElement *)parent;

@end
