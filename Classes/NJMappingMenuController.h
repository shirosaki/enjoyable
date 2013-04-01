//
//  NJMappingMenuController.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/11/13.
//
//

#import <Foundation/Foundation.h>

@class NJMapping;

@protocol NJMappingMenuDelegate

- (void)mappingWasChosen:(NJMapping *)mapping;
    // Called when a menu item created by the controller is chosen.

- (void)mappingListShouldOpen;
    // Called when the "overflow" menu item is chosen, this means the
    // user should be presented with the list of available mappings.

@end

@interface NJMappingMenuController : NSObject
    // Mapping menu controllers manage the contents of a menu that
    // shows a list of all available mappings, as well as the current
    // event simulation state. The menu may have other items in it as
    // well, but none at an adjacent index that also have NJMappings
    // as represented objects.

@property (nonatomic, strong) IBOutlet NSMenu *menu;
    // The menu to put mapping items in.

@property (nonatomic, weak) IBOutlet id <NJMappingMenuDelegate> delegate;
    // The delegate to inform about requested mapping changes.

@property (nonatomic, assign) NSInteger firstMappingIndex;
    // The index in the menu to insert mappings into. The menu can
    // have other dynamic items as long as you update this index as
    // you add or remove them.

@property (nonatomic, assign) BOOL hasKeyEquivalents;
    // Whether or not to add key equivalents to the menu items.

@property (nonatomic, strong) IBOutlet NSMenuItem *eventSimulationToggle;
    // A menu item representing the current event simulation state.
    // This outlet is optional.

@end
