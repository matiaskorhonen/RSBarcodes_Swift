//
//  BarcodeReaderViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//
//  Updated by Jarvie8176 on 01/21/2016
//
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes

class BarcodeReaderViewController: RSCodeReaderViewController {
    
    @IBOutlet var toggle: UIButton!
    
    @IBAction func switchCamera(sender: AnyObject?) {
        let position = self.switchCamera()
        if position == AVCaptureDevicePosition.Back {
            print("back camera.")
        } else {
            print("front camera.")
        }
    }
    
    @IBAction func close(sender: AnyObject?) {
        print("close called.")
    }
    
    @IBAction func toggle(sender: AnyObject?) {
        let isTorchOn = self.toggleTorch()
        print(isTorchOn)
    }
    
    var barcode: String = ""
    var dispatched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: NOTE: Uncomment the following line to enable crazy mode
        // self.isCrazyMode = true
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        
        self.tapHandler = { point in
            print(point)
        }
        
        // MARK: NOTE: If you want to detect specific barcode types, you should update the types
        let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
        // MARK: NOTE: Uncomment the following line remove QRCode scanning capability
        // types.removeObject(AVMetadataObjectTypeQRCode)
        self.output.metadataObjectTypes = NSArray(array: types) as [AnyObject]
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview)
        }
        
        if !self.hasTorch() {
            self.toggle.enabled = false
        }
        
        self.barcodesHandler = { barcodes in
            if !self.dispatched { // triggers for only once
                self.dispatched = true
                for barcode in barcodes {
                    self.barcode = barcode.stringValue
                    print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("nextView", sender: self)
                        
                        // MARK: NOTE: Perform UI related actions here.
                    })
                    
                    // MARK: NOTE: break here to only handle the first barcode object
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dispatched = false // reset the flag so user can do another scan
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationController?.navigationBarHidden = false
        
        if segue.identifier == "nextView" {
            let destinationVC = segue.destinationViewController as! BarcodeDisplayViewController
            if !self.barcode.isEmpty {
                destinationVC.contents = self.barcode
            }
        }
    }
}