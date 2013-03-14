//
//  NJInputButton.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJInput.h"

@interface NJInputButton : NJInput

- (id)initWithElement:(IOHIDElementRef)element
                index:(int)index
               parent:(NJInputPathElement *)parent;

@end
