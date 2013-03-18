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

- (void)addedDevice:(NJDevice *)device atIndex:(NSUInteger)idx;
- (void)removedDevice:(NJDevice *)device atIndex:(NSUInteger)idx;
    // But using these will animate nicely.

- (void)hidStarted;
- (void)hidStopped;

- (void)beginUpdates;
- (void)endUpdates;

- (void)expandAndSelectItem:(NJInputPathElement *)item;

- (NJInputPathElement *)selectedHandler;

@end

@protocol NJDeviceViewControllerDelegate <NSObject>

- (NSInteger)numberOfDevicesInDeviceList:(NJDeviceViewController *)dvc;
- (NJDevice *)deviceViewController:(NJDeviceViewController *)dvc
                    deviceForIndex:(NSUInteger)idx;
- (NJInputPathElement *)deviceViewController:(NJDeviceViewController *)dvc
                               elementForUID:(NSString *)uid;


- (void)deviceViewController:(NJDeviceViewController *)dvc
             didSelectDevice:(NJInputPathElement *)device;
- (void)deviceViewController:(NJDeviceViewController *)dvc
             didSelectBranch:(NJInputPathElement *)handler;
- (void)deviceViewController:(NJDeviceViewController *)dvc
            didSelectHandler:(NJInputPathElement *)handler;
- (void)deviceViewControllerDidSelectNothing:(NJDeviceViewController *)dvc;

@end
