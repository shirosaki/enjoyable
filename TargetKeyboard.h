//
//  TargetKeyboard.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "Target.h"

@interface TargetKeyboard : Target

@property (assign) CGKeyCode vk;
@property (readonly) NSString* descr;

@end
