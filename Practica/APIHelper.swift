//
//  APIHelper.swift
//  Practica
//
//  Created by Rodrigo Solís Morales on 30/05/15.
//  Copyright (c) 2015 Rodrigo Solís Morales. All rights reserved.
//

import Foundation


enum HTTPRequestContentType {
    case HTTPJsonContent
    case HTTPMultipartContent
}

struct APIHelper {
    
    static let BASE_URL = "http://XXXX.YYY"
    
    func buildRequest(path: String!, method: String, requestContentType: HTTPRequestContentType = HTTPRequestContentType.HTTPJsonContent, requestBoundary:String = "") -> NSMutableURLRequest {
        // 1. Create the request URL from path
        let requestURL = NSURL(string: "\(APIHelper.BASE_URL)/\(path)")
        var request = NSMutableURLRequest(URL: requestURL!)
        
        // Set HTTP request method and Content-Type
        request.HTTPMethod = method
        
        // 2. Set the correct Content-Type for the HTTP Request. This will be multipart/form-data for photo upload request and application/json for other requests in this app
        switch requestContentType {
        case .HTTPJsonContent:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .HTTPMultipartContent:
            let contentType = "multipart/form-data; boundary=\(requestBoundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    func sendRequest(request: NSURLRequest, completion:(NSData!, NSError!) -> Void) -> () {
        // Create a NSURLSession task
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(data, error)
                })
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(data, nil)
                    } else {
                        var jsonerror:NSError?
                        if let errorDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as? NSDictionary {
                            let responseError : NSError = NSError(domain: "HTTPHelperError", code: httpResponse.statusCode, userInfo: errorDict as? [NSObject : AnyObject])
                            completion(data, responseError)
                        }
                    }
                }
            })
        }
        
        // start the task
        task.resume()
    }
    
    func uploadRequest(path: String, data: NSData!, owner: String, friends: [String]) -> NSMutableURLRequest {
        var error:NSError?
        let boundary = "---------------------------14737809831466499882746641449"
        var request = buildRequest(path, method: "POST",
            requestContentType:HTTPRequestContentType.HTTPMultipartContent, requestBoundary:boundary) as NSMutableURLRequest
        
        let bodyParams : NSMutableData = NSMutableData()
        
        // build and format HTTP body with data
        // prepare for multipart form uplaod
        
        let boundaryString = "--\(boundary)\r\n"
        let boundaryData = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        bodyParams.appendData(boundaryData)
        
        // set the parameter name
        let imageMeteData = "Content-Disposition: form-data; name=\"photo\"; filename=\"filename1.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(imageMeteData!)
        
        // set the content type
        let fileContentType = "Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(fileContentType!)
        
        // add the actual image data
        if data != nil {
            bodyParams.appendData(data)
        }
        
        let imageDataEnding = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(imageDataEnding!)
        
        // pass the owner
        let boundaryString2 = "--\(boundary)\r\n"
        let boundaryData2 = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        
        bodyParams.appendData(boundaryData2)
        
        let formData = "Content-Disposition: form-data; name=\"owner\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(formData!)
        
        let ownerData = owner.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(ownerData!)
        
        let closingFormData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(closingFormData!)
        
        // pass the friends list
        let boundaryString3 = "--\(boundary)\r\n"
        let boundaryData3 = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        
        bodyParams.appendData(boundaryData2)
        
        let formData2 = "Content-Disposition: form-data; name=\"friends\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(formData2!)
        
        let friendsData = NSJSONSerialization.dataWithJSONObject(friends, options: nil, error: &error)
        bodyParams.appendData(friendsData!)
        
        let closingFormData2 = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(closingFormData2!)
        
        
        let closingData = "--\(boundary)--\r\n"
        let boundaryDataEnd = closingData.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        
        bodyParams.appendData(boundaryDataEnd)
        
        request.HTTPBody = bodyParams
        return request
    }
    
    func getErrorMessage(error: NSError) -> NSString {
        var errorMessage : NSString
        
        // return correct error message
        if error.domain == "HTTPHelperError" {
            let userInfo = error.userInfo as NSDictionary!
            errorMessage = userInfo.valueForKey("message") as! NSString
        } else {
            errorMessage = error.description
        }
        
        return errorMessage
    }
    
}