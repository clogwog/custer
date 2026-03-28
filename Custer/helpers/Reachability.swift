//
//  Reachability.swift
//  custer
//
//  Created by Serhiy Mytrovtsiy on 28/03/2026.
//  Using Swift 5.0.
//  Running on macOS 10.15.
//
//  Copyright © 2020 Serhiy Mytrovtsiy. All rights reserved.
//

import Network

public class Reachability {
    public var whenReachable: (() -> Void)?
    public var whenUnreachable: (() -> Void)?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "reachability.monitor")
    private var isReachable: Bool = true
    
    public var isConnected: Bool { self.isReachable }
    
    public init() {
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let reachable = path.status == .satisfied
            if reachable != self.isReachable {
                self.isReachable = reachable
                DispatchQueue.main.async {
                    if reachable {
                        self.whenReachable?()
                    } else {
                        self.whenUnreachable?()
                    }
                }
            }
        }
    }
    
    public func start() {
        self.monitor.start(queue: self.queue)
    }
    
    public func stop() {
        self.monitor.cancel()
    }
    
    deinit {
        self.stop()
    }
}
