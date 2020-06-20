//
//  OCR.swift
//  Microsoft-OCR-Translation
//
//  Created by Pawan kumar on 20/06/20.
//  Copyright © 2020 Pawan Kumar. All rights reserved.
//

import Foundation

typealias OCRRequestObject = (resource: Any, language: OCR.Langunages, detectOrientation: Bool)

class OCR: NSObject {
    
    // Base URL
    let url = "https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr"
    
    // API Key
    let key = "API Key"
    
    // Detectable Languages
    enum Langunages: String {
        case Automatic = "unk"
        case ChineseSimplified = "zh-Hans"
        case ChineseTraditional = "zh-Hant"
        case Czech = "cs"
        case Danish = "da"
        case Dutch = "nl"
        case English = "en"
        case Finnish = "fi"
        case French = "fr"
        case German = "de"
        case Greek = "el"
        case Hungarian = "hu"
        case Italian = "it"
        case Japanese = "Ja"
        case Korean = "ko"
        case Norwegian = "nb"
        case Polish = "pl"
        case Portuguese = "pt"
        case Russian = "ru"
        case Spanish = "es"
        case Swedish = "sv"
        case Turkish = "tr"
    }
    
    enum RecognizeCharactersErrors: Error {
        case unknownError
        case imageUrlWrongFormatted
        case emptyDictionary
    }
    
    func recognizeCharactersWithRequestObject(_ requestObject: OCRRequestObject, completion: @escaping (_ response: [String:AnyObject]? ) -> Void) throws {

        // Generate the url
        let requestUrlString = url + "?language=" + requestObject.language.rawValue + "&detectOrientation%20=\(requestObject.detectOrientation)"
        let requestUrl = URL(string: requestUrlString)
        
        
        var request = URLRequest(url: requestUrl!)
        request.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        // Request Parameter
        if let path = requestObject.resource as? String {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"url\":\"\(path)\"}".data(using: String.Encoding.utf8)
        }
        else if let imageData = requestObject.resource as? Data {
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
        }
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            if error != nil{
                completion(nil)
                return
            }else{
                let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                
                // Hand dict over
                DispatchQueue.main.async {
                    completion(results)
                }
            }
            
        }
        task.resume()
    }
    
    func extractStringsFromDictionary(_ dictionary: [String : AnyObject]) -> [String] {
        if dictionary["regions"] != nil {
            var extractedText : String = ""
            
            if let regionsz = dictionary["regions"] as? [AnyObject]{
                for reigons1 in regionsz
                {
                    if let reigons = reigons1 as? [String:AnyObject]
                    {
                        let lines = reigons["lines"] as! NSArray
                        print (lines)
                        for words in lines{
                            if let wordsArr = words as? [String:AnyObject]{
                                if let dictionaryValue = wordsArr["words"] as? [AnyObject]{
                                    for a in dictionaryValue {
                                        if let z = a as? [String : String]{
                                            print (z["text"]!)
                                            extractedText += z["text"]! + " "
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            // Get text from words
            return [extractedText]
        }
        else
        {
            return [""];
        }
    }
   
    func extractStringFromDictionary(_ dictionary: [String:AnyObject]) -> String {
        
        let stringArray = extractStringsFromDictionary(dictionary)
        
        let reducedArray = stringArray.enumerated().reduce("", {
                $0 + $1.element + ($1.offset < stringArray.endIndex-1 ? " " : "")
            }
        )
        return reducedArray
    }
}
