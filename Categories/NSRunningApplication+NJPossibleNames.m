//
//  NSRunningApplication+NJPossibleNames.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/8/13.
//
//

#import "NSRunningApplication+NJPossibleNames.h"

@implementation NSRunningApplication (NJPossibleNames)

- (NSArray *)possibleMappingNames {
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:4];
    if (self.bundleIdentifier)
        [names addObject:self.bundleIdentifier];
    if (self.localizedName)
        [names addObject:self.localizedName];
    if (self.bundleURL)
        [names addObject:[self.bundleURL.lastPathComponent stringByDeletingPathExtension]];
    if (self.executableURL)
        [names addObject:self.executableURL.lastPathComponent];
    return names;
}

- (NSString *)bestMappingName {
    // A number of Flash applications all use the generic Flash bundle
    // ID and localized name, but they name their bundle file and
    // executable correctly. Don't want to fall back to those IDs
    // unless we absolutely have to.
    NSArray *genericBundles = @[
        @"com.macromedia.Flash Player Debugger.app",
        @"com.macromedia.Flash Player.app",
        ];
    BOOL probablyWrong = [genericBundles containsObject:self.bundleIdentifier];
    if (!probablyWrong && self.localizedName)
        return self.localizedName;
    else if (!probablyWrong && self.bundleIdentifier)
        return self.bundleIdentifier;
    else if (self.bundleURL)
        return [self.bundleURL.lastPathComponent stringByDeletingPathExtension];
    else if (self.executableURL)
        return self.executableURL.lastPathComponent;
    else if (self.localizedName)
        return self.localizedName;
    else if (self.bundleIdentifier)
        return self.bundleIdentifier;
    else {
        return NSLocalizedString(@"@Application",
                                 @"Magic string to trigger automatic "
                                 @"mapping renames. It should look like "
                                 @"an identifier rather than normal "
                                 @"word, with the @ on the front.");
    }
}

@end
