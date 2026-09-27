//
//  FrameworkExtension.swift
//  Aperture
//

import UIKit
import SwiftUI

class OverlayWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == rootViewController?.view {
            return nil
        }
        
        return hitView
    }
}

@objc public class OverlayManager: NSObject {
    @objc public static let shared = OverlayManager()
    private var overlayWindow: OverlayWindow?
    
    @objc public func showOverlay(on windowScene: UIWindowScene) {
        let window = OverlayWindow(windowScene: windowScene)
        
        applyDesiredOverlayBounds(window: window, bounds: windowScene.screen.bounds)
        
        window.backgroundColor = .clear
        window.windowLevel = .alert + 2000
        
        let overlay = FrameworkOverlay(ctx: FrameworkOverlayContext(
            hostWindow: nil
        ))
        let controller = UIHostingController(rootView: overlay)
        controller.view.backgroundColor = .clear
        
        window.rootViewController = controller
        
        self.overlayWindow = window
        window.isHidden = false
    }
}

func applyDesiredOverlayBounds(window: UIWindow, bounds: CGRect) {
    /*let desiredHeight = bounds.height * 0.10;
    let frame = CGRect(x: 0, y: 0, width: bounds.width, height: desiredHeight)*/
    
    let frame = bounds
    
    window.frame = frame
}

struct FrameworkOverlayContext {
    weak var hostWindow: UIWindow?
}

struct FrameworkOverlay: View {
    var ctx: FrameworkOverlayContext
    
    var body: some View {
        IndexMenuView(ctx: ctx)
        Spacer()
    }
}

struct PopoverData: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

private class BundleLocationClass {
    public static var version: String {
        let bundle = Bundle(for: BundleLocationClass.self)
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

struct IndexMenuView: View {
    var ctx: FrameworkOverlayContext
    @State private var popoverData: PopoverData?
    @State private var activeHttpProxy = HttpProxy.shared
    
    let sharedExtensionRegistry: ApertureFrameworkExtensionRegistry = ApertureFrameworkExtensionRegistry.shared;
    
    var body: some View {
        Menu {
            Label("Aperture Toolbar v\(BundleLocationClass.version)", systemImage: "camera.aperture")
            
            Divider()
            
            Menu("Window Inspection") {
                Button {
                    popoverData = PopoverData(
                        title: "UIWindow Data:",
                        description: "\(ctx.hostWindow != nil ? "\(ctx.hostWindow!)" : "Error: Host window not available.")"
                    )
                } label: {
                    Label("Element Picker", systemImage: "pointer.arrow.ipad.rays")
                }
            }
            
            Menu("Network Inspection") {
                if activeHttpProxy.isActive {
                    Menu {
                        Button {
                            popoverData = PopoverData(
                                title: "HTTP History",
                                description: activeHttpProxy.requestHistory.compactMap { $0.url?.absoluteString }.joined(separator: "\n")
                            )
                        } label: {
                            Label("Open History", systemImage: "network.badge.shield.half.filled")
                        }
                        
                        Button {
                            activeHttpProxy.endProxy()
                        } label: {
                            Label("Stop Proxying", systemImage: "network.slash")
                        }
                    } label: {
                        Label("Active HTTP Proxy", systemImage: "network.badge.shield.half.filled")
                    }
                } else {
                    Button {
                        activeHttpProxy.startProxying()
                    } label: {
                        Label("Enable HTTP Proxy Inspection", systemImage: "network.badge.shield.half.filled")
                    }
                }
            }
            
            Divider()
            
            if sharedExtensionRegistry.menuExtensions.count > 0 {
                ForEach(sharedExtensionRegistry.menuExtensions as? [ExtensionMenu] ?? [], id:\.self) { item in
                    Menu(item.name) {
                        ForEach(item.elements, id:\.self) { elem in
                            Button(elem.name) {
                                elem.callback();
                            }
                        }
                    }
                }
                
                Divider()
            }
            
            Button {
                
            } label: {
                Label("Close", systemImage: "xmark")
            }
        } label: {
            Image(systemName: "camera.aperture")
                .font(.headline)
                .padding()
                .glassEffect(.regular, in: Capsule())
        }
        .foregroundStyle(.primary)
        .popover(item: $popoverData) { data in
            VStack {
                Text(data.title)
                    .font(.headline)
                Text(data.description)
                    .padding()
            }
        }
    }
}
