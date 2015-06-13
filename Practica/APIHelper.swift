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
    
    static let BASE_URL = "XXXX.YY"
    
    func buildRequest(path: String!, method: String, requestContentType: HTTPRequestContentType = HTTPRequestContentType.HTTPJsonContent, requestBoundary:String = "") -> NSMutableURLRequest {
        // 1.Se crea la request con un path
        let requestURL = NSURL(string: "\(APIHelper.BASE_URL)/\(path)")
        var request = NSMutableURLRequest(URL: requestURL!)
        
        // Se establece el metodo http
        request.HTTPMethod = method
        
        // 2. Se elige el content type entre multipart/form-data y application/json
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
        // Se crea una task NSURLSession
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
        
        // Se inicia la task
        task.resume()
    }
    
    func uploadRequest(path: String, data: NSData!, owner: String, friends: [String]) -> NSMutableURLRequest {
        var error:NSError?
        let boundary = "---------------------------14737809831466499882746641449"
        var request = buildRequest(path, method: "POST",
            requestContentType:HTTPRequestContentType.HTTPMultipartContent, requestBoundary:boundary) as NSMutableURLRequest
        
        let bodyParams : NSMutableData = NSMutableData()
        
        // Se construye y se da formato al body de la http request
        
        
        let boundaryString = "--\(boundary)\r\n"
        let boundaryData = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        bodyParams.appendData(boundaryData)
        
        // Se establece el name del parametro
        let imageMeteData = "Content-Disposition: form-data; name=\"photo\"; filename=\"filename1.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(imageMeteData!)
        
        //Se establece el content type
        let fileContentType = "Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(fileContentType!)
        
        // Se añade la data de la imagen
        if data != nil {
            bodyParams.appendData(data)
        }
        
        let imageDataEnding = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(imageDataEnding!)
        
        // Se añade el owner
        let boundaryString2 = "--\(boundary)\r\n"
        let boundaryData2 = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        
        bodyParams.appendData(boundaryData2)
        
        let formData = "Content-Disposition: form-data; name=\"owner\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(formData!)
        
        let ownerData = owner.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(ownerData!)
        
        let closingFormData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(closingFormData!)
        
        // Se añade el array a enviar
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
        
        // devuelve el mensaje de error adecuado
        if error.domain == "HTTPHelperError" {
            let userInfo = error.userInfo as NSDictionary!
            errorMessage = userInfo.valueForKey("message") as! NSString
        } else {
            errorMessage = error.description
        }
        
        return errorMessage
    }
    
}