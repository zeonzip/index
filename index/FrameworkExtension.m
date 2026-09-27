//
//  FrameworkExtension.m
//  Aperture
//

#import <Foundation/Foundation.h>
#import <FrameworkExtension.h>

@implementation ExtensionMenuElement : NSObject
- (instancetype)initMenuElement:(NSString*)name callback:(ElementClickedClosure)callback {
    self = [super init];
    
    if (self) {
        self.name = name;
        self.callback = callback;
    }
    
    return self;
}
@end

@implementation ExtensionMenu : NSObject

- (instancetype)initMenu:(NSString*)name elements:(NSArray<ExtensionMenuElement *> *)elements {
    self = [super init];
    
    if (self) {
        self.name = name;
        self.elements = elements;
    }
    
    return self;
}

@end


@implementation ApertureFrameworkExtensionRegistry : NSObject
- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.menuExtensions = [NSMutableArray new];
    }
    
    return self;
}

+ (instancetype)sharedRegistry {
    static ApertureFrameworkExtensionRegistry *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)registerExtension:(id<ApertureFrameworkExtension>)extension {
    [self.menuExtensions addObject:[extension retrieveMenu]];
}
@end
