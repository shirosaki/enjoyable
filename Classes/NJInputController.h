//
//  NJInputController.h
//  Enjoyable
//

#import "NJHIDManager.h"

@class NJDevice;
@class NJInput;
@class NJInputPathElement;
@class NJMapping;

@protocol NJInputControllerDelegate;

@interface NJInputController : NSObject <NJHIDManagerDelegate>

@property (nonatomic, weak) IBOutlet id <NJInputControllerDelegate> delegate;

@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, assign) BOOL simulatingEvents;
@property (nonatomic, readonly) NSArray *devices;

@property (nonatomic, readonly) NJMapping *currentMapping;
@property (nonatomic, readonly) NSArray *mappings;

- (NJMapping *)mappingForKey:(NSString *)name;
- (NSInteger)indexOfMapping:(NJMapping *)mapping;

- (void)addMapping:(NJMapping *)mapping;
- (void)insertMapping:(NJMapping *)mapping atIndex:(NSInteger)idx;
- (void)removeMappingAtIndex:(NSInteger)idx;
- (void)mergeMapping:(NJMapping *)mapping intoMapping:(NJMapping *)existing;
- (void)moveMoveMappingFromIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;
- (void)renameMapping:(NJMapping *)mapping to:(NSString *)name;

- (void)activateMapping:(NJMapping *)mapping;
- (void)activateMappingForProcess:(NSRunningApplication *)app;

- (void)save;
- (void)load;

- (NJInputPathElement *)elementForUID:(NSString *)uid;

@end

@protocol NJInputControllerDelegate

- (void)inputController:(NJInputController *)ic didAddDevice:(NJDevice *)device;
- (void)inputController:(NJInputController *)ic didRemoveDeviceAtIndex:(NSInteger)idx;
- (void)inputController:(NJInputController *)ic didInput:(NJInput *)input;
- (void)inputControllerDidStartHID:(NJInputController *)ic;
- (void)inputControllerDidStopHID:(NJInputController *)ic;
- (void)inputController:(NJInputController *)ic didError:(NSError *)error;

@end
