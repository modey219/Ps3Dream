// Ps3Dream iOS - Link-time stub for MTLResidencySetDescriptor
//
// The prebuilt libMoltenVK.a (v1.4.2-rc1) references the Metal class
// MTLResidencySetDescriptor unconditionally from its prelink object. That
// class only exists in macOS 15+ / iOS 18+ Metal, so linking against the
// iOS 17 SDK fails with an undefined _OBJC_CLASS_$_MTLResidencySetDescriptor.
//
// MoltenVK gates residency-set usage at runtime (mvkOSVersionIsAtLeast(...)),
// so on iOS < 18 this stub class is never instantiated. On iOS 18+ MoltenVK
// may interact with this stub class; residency sets are not required for
// basic Vulkan rendering.

#import <Foundation/Foundation.h>

@interface MTLResidencySetDescriptor : NSObject
@property (nonatomic, copy) NSString *label;
@property (nonatomic) NSUInteger initialCapacity;
@end

@implementation MTLResidencySetDescriptor
@end
