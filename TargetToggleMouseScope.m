//
//  TargetToggleMouseScope.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetToggleMouseScope.h"

@implementation TargetToggleMouseScope

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"mtoggle"];
}

+(TargetToggleMouseScope*) unstringifyImpl: (NSArray*) comps {
	NSParameterAssert([comps count] == 1);
	TargetToggleMouseScope* target = [[TargetToggleMouseScope alloc] init];
	return target;
}

- (void)trigger {
    // FIXME: It's hacky to get at the controller this way, but it's
    // also hacky to pass it. Shouldn't need to do either.
    ApplicationController *ac = [NSApplication sharedApplication].delegate;
    JoystickController *jc = ac.jsController;
    [jc setFrontWindowOnly: ![jc frontWindowOnly]];
    printf("Front window only: %d\n", [jc frontWindowOnly]);
}

@end
