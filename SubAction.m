//
//  SubAction.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

// TODO(jfw): This class is useless and can just be replaced w/ JSAction probably.

#import "SubAction.h"

@implementation SubAction

- (id)initWithIndex:(int)newIndex name:(NSString *)newName base:(JSAction *)newBase {
	if ((self = [super init])) {
        self.name = newName;
        self.base = newBase;
        self.index = newIndex;
	}
	return self;
}

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"%@~%d", [base stringify], self.index];
}

@end
