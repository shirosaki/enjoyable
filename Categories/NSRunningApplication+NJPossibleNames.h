//
//  NSRunningApplication+NJPossibleNames.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/8/13.
//
//

#import <Cocoa/Cocoa.h>

@interface NSRunningApplication (NJPossibleNames)

- (NSArray *)possibleMappingNames;
    // Return a list of mapping names this application could match.

- (NSString *)bestMappingName;
    // Return the best mapping name, taking into account ways in which
    // application names are often broken.

@end
