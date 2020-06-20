//
//  TranslationScreen.swift
//  Microsoft-OCR-Translation
//
//  Created by Pawan kumar on 20/06/20.
//  Copyright © 2020 Pawan Kumar. All rights reserved.
//

import UIKit
import Foundation
import SceneKit
import ARKit

class TranslationScreen: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
     
    @IBOutlet weak var ocrTitleLabel: UILabel!
    @IBOutlet weak var ocrLabel: UILabel!
    @IBOutlet weak var translationTitleLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    
    var textStrig: String = ""
    
    let ocr = OCR()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Loader
        textStrig = ""
        self.ocrLabel.text = ""
        self.translationLabel.text = ""
        
        //Refresh
        self.takePhotoCotinously()
        
        //Connfiguration ARKit
        self.configurationARKit()
    }
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func configurationARKit() {
           
           // Configure the ARSCNView which will be used to display the AR content.
           sceneView.delegate = self
           
           // Since we will also capture from the view we will limit ourselves to 30 fps.
           sceneView.preferredFramesPerSecond = 60
           // Since we are in a streaming environment, we will render at a relatively low resolution.
           sceneView.contentScaleFactor = 1

           start()
       }
       func start() {
           // Starting capture is a two step process. We need to start the ARSession and schedule the CADisplayLinkTimer.
           let configuration = ARWorldTrackingConfiguration()
           sceneView.session.run(configuration)
       }
    
    func stop() {
          self.sceneView.session.pause()
      }
    
    
    @objc func takePhotoCotinously() {
       
        //Refresh Image After Every 5 Second
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // your function here
            self.didTakePhoto()
        }
    }

    @objc func didTakePhoto() {
       
        let currentFrame = self.sceneView.snapshot
       
        //Convert Image to Givin Size
        let senndImage: UIImage = currentFrame()

        print("Image Found")
        
        recognizeImageWithGoogleMobileVision(image: senndImage)
    
    }
    
    func recognizeImageWithGoogleMobileVision(image: UIImage) -> () {
        
        //Loader
        textStrig = ""
        self.ocrLabel.text = ""
        self.translationLabel.text = ""
        
        let requestObject: OCRRequestObject = (resource: image, language: .Automatic, detectOrientation: true)
        try! ocr.recognizeCharactersWithRequestObject(requestObject, completion: { (response) in
            if (response != nil){
                let text = self.ocr.extractStringFromDictionary(response!)
                self.textStrig = text
                
                DispatchQueue.main.async {
                    
                    //Update UI Part
                    self.ocrLabel.text = self.textStrig
                    
                    if self.textStrig.count > 0 {
                        //Refresh
                        self.translateGoogleapisApi(text: self.textStrig)
                    }
                
                    //Refresh
                    self.takePhotoCotinously()
                }
            }
        })
    }
    
    func translateGoogleapisApi(text: String) -> () {
        
        let parameters = [
            "sl" : "en",
            "tl" : "hi",
            "dt" : "t",
            "q" : text
        ]
    
        APIManager.shared.translateGoogleapisApi(parameters: parameters, completionHandler: { (jsonResponse) -> Void in
            
            if jsonResponse.count > 0 {
                let firstList = jsonResponse.first
                let firstListArray = firstList as! Array<Any>
                let secondList = firstListArray.first
                let secondListArray = secondList as! Array<Any>
                let txt = secondListArray.first
                let textTranslate = txt as! String
                print("textTranslate ", textTranslate)
                
                DispatchQueue.main.async {
                    //Update UI Part
                    self.translationLabel.text = textTranslate
                }
            }
        })
    }
}


