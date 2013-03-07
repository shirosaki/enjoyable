//
//  NSString+FixFilename.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import "NSString+FixFilename.h"

@implementation NSString (FixFilename)

- (NSString *)stringByFixingPathComponent {
    static NSCharacterSet *invalid;
    if (!invalid)
        invalid = [NSCharacterSet characterSetWithCharactersInString:@"/:"];
    NSArray *parts = [self componentsSeparatedByCharactersInSet:invalid];
    NSString *newName = [parts componentsJoinedByString:@""];
    if (!newName.length)
        return @"_";
    if ([newName characterAtIndex:0] == '.')
        newName = [@"_" stringByAppendingString:newName];
    return newName;
}

@end
