//
//  FrameworkExtension.h
//  Aperture
//

#import <Foundation/Foundation.h>

typedef void (^ElementClickedClosure)(void);

@interface ExtensionMenuElement : NSObject

@property (nonatomic, strong) ElementClickedClosure callback;
@property (nonatomic, strong) NSString* name;

- (instancetype)initMenuElement:(NSString*)name callback:(ElementClickedClosure)callback;

@end

@interface ExtensionMenu : NSObject

@property (nonatomic, strong) NSArray<ExtensionMenuElement *> *elements;
@property (nonatomic, strong) NSString* name;

- (instancetype)initMenu:(NSString*)name elements:(NSArray<ExtensionMenuElement *> *)elements;

@end

@protocol ApertureFrameworkExtension <NSObject>

@required
- (ExtensionMenu *)retrieveMenu;

@property (nonatomic, readonly, strong) NSString *extensionName;

@end

@interface ApertureFrameworkExtensionRegistry : NSObject

@property NSMutableArray<ExtensionMenu *> *menuExtensions;

@property(class, readonly, strong) ApertureFrameworkExtensionRegistry* sharedRegistry;
- (void)registerExtension:(id<ApertureFrameworkExtension>)extension;

@end
