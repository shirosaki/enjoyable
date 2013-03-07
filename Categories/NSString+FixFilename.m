//
//  NSString+FixFilename.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import "NSString+FixFilename.h"

@implementation NSCharacterSet (FixFilename)

+ (NSCharacterSet *)invalidPathComponentCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:@"\"\\/:*?<>|"];
}

@end

@implementation NSString (FixFilename)

- (NSString *)stringByFixingPathComponent {
    NSCharacterSet *invalid = NSCharacterSet.invalidPathComponentCharacterSet;
    NSCharacterSet *whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet;
    NSArray *parts = [self componentsSeparatedByCharactersInSet:invalid];
    NSString *name = [parts componentsJoinedByString:@"_"];
    name = [name stringByTrimmingCharactersInSet:whitespace];
    if (!name.length)
        return @"_";
    unichar first = [name characterAtIndex:0];
    if (first == '.' || first == '-')
        name = [@"_" stringByAppendingString:name];
    return name;
}

@end
