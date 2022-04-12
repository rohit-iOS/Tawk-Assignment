//
//  SequentialOpertion.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 13/04/2022.
//

import Foundation

enum OperationState : Int {
    case ready
    case executing
    case finished
}

/// Class to make only one operation at a time
class SequentialOpertion : Operation {
        
    ///Properties
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    
    private var dataTask : URLSessionDataTask!
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    init(session: URLSession, dataTaskURLRequest: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        
        dataTask = session.dataTask(with: dataTaskURLRequest, completionHandler: { [weak self] (data, response, error) in
            if let completionHandler = completionHandler {
                completionHandler(data, response, error)
            }
            self?.state = .finished
        })
    }
    
    override func start() {
        state = .executing
        print("API request in progress \(self.dataTask.originalRequest?.url?.absoluteString ?? "")")
        self.dataTask.resume()
    }
}
