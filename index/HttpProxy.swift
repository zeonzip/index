//
//  HttpProxy.swift
//  index
//

import Foundation

@Observable
final class HttpProxy {
    static var shared: HttpProxy = HttpProxy()
    
    var isActive = false
    var requestHistory: [URLRequest] = []
    
    private init() {}
    
    func startProxying() {
        if isActive { return }
        
        URLProtocol.registerClass(ProxyDummyProtocol.self)
        isActive = true
    }
    
    func endProxy() {
        URLProtocol.unregisterClass(ProxyDummyProtocol.self)
        isActive = false
        requestHistory = []
    }
}

struct ProxyRequestData {
    
}

@objc public class ProxyDummyProtocol: URLProtocol {
    @objc public override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        
        if url.scheme == "http" || url.scheme == "https" {
            if HttpProxy.shared.isActive {
                HttpProxy.shared.requestHistory.append(request)
            }
        }
        
        return false
    }
}
