//
//  JSActionButton.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JSAction.h"

@interface JSActionButton : JSAction

- (id)initWithName:(NSString *)name idx:(int)idx max:(int)max;

@property (assign) int max;

@end
