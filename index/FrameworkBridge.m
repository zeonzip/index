//
//  FrameworkBridge.m
//  index
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <index-Swift.h>

static void notFoundError(void) {
    NSLog(@"error while swizzling http proxy: swizzled or original instance method not found.");
}

@implementation NSURLSessionConfiguration (FrameworkExtension)

+ (void)swizzleHttpProxyProtocol {
    Class specific = object_getClass([NSURLSessionConfiguration defaultSessionConfiguration]);
    
    SEL originalSel = @selector(protocolClasses);
    SEL swizzledSel = @selector(swizzledProtocolClasses);
    
    Method originalMethod = class_getInstanceMethod(specific, originalSel);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSel);
    
    if (!originalMethod || !swizzledMethod) {
        notFoundError();
        return;
    }
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (NSArray<Class> *)swizzledProtocolClasses {
    NSArray<Class> *existing = [self swizzledProtocolClasses] ?: @[];
    
    if ([existing containsObject:[ProxyDummyProtocol class]]) {
        return existing;
    }
    
    return [@[[ProxyDummyProtocol class]] arrayByAddingObjectsFromArray:existing];
}

@end

@interface OverlayManager (IndexExtension)
- (void) handleSceneReady:(NSNotification*)notification;
@end

@implementation OverlayManager (IndexExtension)
- (void) handleSceneReady:(NSNotification*)notification {
    if (notification.object == NULL || ![notification.object isKindOfClass:[UIWindowScene class]]) {
        NSLog(@"Notification sent from UIScene did not contain a UIWindowScene object, error.");
        return;
    }
    
    UIWindowScene *scene = (UIWindowScene*)notification.object;
    
    [self showOverlayOn:scene];
}
@end

static void registerOverlayManagerObserver(void) {
    OverlayManager *manager = [OverlayManager shared];
    
    [NSNotificationCenter.defaultCenter addObserver:manager
                                           selector: @selector(handleSceneReady:)
                                               name: UISceneDidActivateNotification
                                             object: NULL];
}

static void swizzleProtocol(void) {
    [NSURLSessionConfiguration swizzleHttpProxyProtocol];
}

__attribute__((constructor))
static void initializeFrameworkHook(void) {
    swizzleProtocol();
    registerOverlayManagerObserver();
}
