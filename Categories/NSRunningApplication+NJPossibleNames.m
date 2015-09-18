//
//  NSRunningApplication+NJPossibleNames.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/8/13.
//
//

#import "NSRunningApplication+NJPossibleNames.h"

@implementation NSRunningApplication (NJPossibleNames)

- (NSArray *)windowTitles {
    static CGWindowListOption s_OPTIONS = (CGWindowListOption)(kCGWindowListOptionOnScreenOnly
                                           | kCGWindowListExcludeDesktopElements);
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:4];
    NSArray *windows = CFBridgingRelease(CGWindowListCopyWindowInfo(s_OPTIONS, kCGNullWindowID));
    for (NSDictionary *props in windows) {
        NSNumber *pid = props[(id)kCGWindowOwnerPID];
        if (pid.longValue == self.processIdentifier && props[(id)kCGWindowName])
            [titles addObject:props[(id)kCGWindowName]];
    }
    return titles;
}

- (NSString *)frontWindowTitle {
    return self.windowTitles[0];
}

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
    if (self.frontWindowTitle)
        [names addObject:self.frontWindowTitle];
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
    NSArray *genericExecutables = @[ @"wine.bin" ];
    BOOL probablyWrong = ([genericBundles containsObject:self.bundleIdentifier]
                          || [genericExecutables containsObject:self.localizedName]);
    if (!probablyWrong && self.localizedName)
        return self.localizedName;
    else if (!probablyWrong && self.bundleIdentifier)
        return self.bundleIdentifier;
    else if (self.bundleURL)
        return [self.bundleURL.lastPathComponent stringByDeletingPathExtension];
    else if (self.frontWindowTitle)
        return self.frontWindowTitle;
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
