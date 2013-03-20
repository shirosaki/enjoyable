//
//  NJDeviceViewController.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/16/13.
//
//

@class NJDevice;
@class NJInput;
@class NJInputPathElement;

@protocol NJDeviceViewControllerDelegate;

@interface NJDeviceViewController : NSObject <NSOutlineViewDataSource,
                                              NSOutlineViewDelegate>

@property (nonatomic, strong) IBOutlet NSOutlineView *inputsTree;
@property (nonatomic, strong) IBOutlet NSView *noDevicesNotice;
@property (nonatomic, strong) IBOutlet NSView *hidStoppedNotice;

@property (nonatomic, weak) IBOutlet id <NJDeviceViewControllerDelegate> delegate;

- (void)addedDevice:(NJDevice *)device atIndex:(NSUInteger)idx;
- (void)removedDeviceAtIndex:(NSUInteger)idx;

- (void)hidStarted;
- (void)hidStopped;

- (void)expandAndSelectItem:(NJInputPathElement *)item;

- (NJInput *)selectedHandler;

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
