//
//  SubAction.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JSAction.h"

@interface SubAction : JSAction

- (id)initWithIndex:(int)newIndex name:(NSString *)newName  base:(JSAction *)newBase;

@property (assign) BOOL active;

@end
