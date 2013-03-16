//
//  NJDeviceViewController.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/16/13.
//
//

@class NJDevice;
@class NJInputPathElement;

@protocol NJDeviceViewControllerDelegate;

@interface NJDeviceViewController : NSObject <NSOutlineViewDataSource,
                                              NSOutlineViewDelegate>

@property (nonatomic, strong) IBOutlet NSOutlineView *inputsTree;
@property (nonatomic, strong) IBOutlet NSView *noDevicesNotice;
@property (nonatomic, strong) IBOutlet NSView *hidStoppedNotice;

@property (nonatomic, weak) IBOutlet id <NJDeviceViewControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *devices;
    // Assigning directly will trigger a full reload.

- (void)addedDevice:(NJDevice *)device atIndex:(NSUInteger)idx;
- (void)removedDevice:(NJDevice *)device atIndex:(NSUInteger)idx;
    // But using these will animate nicely.

- (void)hidStarted;
- (void)hidStopped;

- (void)expandAndSelectItem:(NJInputPathElement *)item;

- (NJInputPathElement *)selectedHandler;

@end

@protocol NJDeviceViewControllerDelegate <NSObject>

- (void)deviceViewController:(NJDeviceViewController *)devices
             didSelectDevice:(NJInputPathElement *)device;
- (void)deviceViewController:(NJDeviceViewController *)devices
             didSelectBranch:(NJInputPathElement *)handler;
- (void)deviceViewController:(NJDeviceViewController *)devices
            didSelectHandler:(NJInputPathElement *)handler;
- (void)deviceViewControllerDidSelectNothing:(NJDeviceViewController *)devices;

@end
