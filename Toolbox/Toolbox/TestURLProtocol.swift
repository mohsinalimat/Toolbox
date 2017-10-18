//
//  TestURLProtocol.swift
//  Toolbox
//
//  Created by gener on 17/10/17.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive
class TestURLProtocol: URLProtocol ,URLSessionDataDelegate {
    var _session:URLSession!
    
    open override class func canInit(with request: URLRequest) -> Bool{
        print(request.url)
        if (TestURLProtocol.property(forKey: "has_start_loading", in: request) != nil){
            return false
        }
        return true
    }
 
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest{
        print(#function)
        return request
    }
    
    override func startLoading() {
        print(#function)
        
        let req = self.request
        guard let _urlpath = req.url else {return  }
        let str = _urlpath.path
        if !FileManager.default.fileExists(atPath: str) {
            let zippath = str + ".zip"
            let zipExist = FileManager.default.fileExists(atPath: zippath)
            if zipExist {
                let desdir = _urlpath.deletingLastPathComponent().path
                SSZipArchive.unzipFile(atPath: zippath, toDestination: "\(desdir)", progressHandler: {(entry, zipinfo, entrynumber, total) in }, completionHandler: {  (path, success, error) in
                        FILESManager.default.deleteFileAt(path: path)
                        self.startTaskWith(req)
                })
            }else{//即使文件不存在也请求一次，由回调处理结果
                startTaskWith(req)
            }
        }else{
            startTaskWith(req)
        }
    }
    
    override func stopLoading() {
        //TestURLProtocol.removeProperty(forKey: "", in: <#T##NSMutableURLRequest#>)
        _session.invalidateAndCancel()
        _session = nil
    }
    
    //MARK:
    func startTaskWith(_ req:URLRequest)  {
        let mutab = NSMutableURLRequest.init(url: req.url!, cachePolicy: req.cachePolicy, timeoutInterval: req.timeoutInterval)
        TestURLProtocol.setProperty(true, forKey: "has_start_loading", in: mutab)
        
        self._session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task =  self._session.dataTask(with: req)
        task.resume()
    }
    
    
    
    //MARK:
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            print(error.localizedDescription)
        }else{
            client?.urlProtocolDidFinishLoading(self)
        }
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print(#function)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(#function)
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
}


