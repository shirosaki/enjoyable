//
//  TargetConfig.m
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//

#import "TargetConfig.h"


@implementation TargetConfig

@synthesize config;

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"cfg~%@", [config name]];
}

+(TargetConfig*) unstringifyImpl: (NSArray*) comps withConfigList: (NSArray*) configs {
	NSParameterAssert([comps count] == 2);
	NSString* name = comps[1];
	TargetConfig* target = [[TargetConfig alloc] init];
	for(int i=0; i<[configs count]; i++)
		if([[configs[i] name] isEqualToString:name]) {
			[target setConfig: configs[i]];
			return target;
		}
	NSLog(@"Warning: couldn't find matching config to restore from: %@",name);
	return NULL;
}

-(void) trigger {
	[[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsController] activateConfig:config];
}

@end
