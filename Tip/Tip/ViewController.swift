//
//  ViewController.swift
//  Tip
//
//  Created by Muin Momin on 12/18/15.
//  Copyright © 2015 Muin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: outlets
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipSlider: UISlider!
    @IBOutlet weak var tipPercentageLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var tipPercentageCaptionLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    
    
    // Helper functions
    func initialHiding() {
        self.bottomView.center.y += 150
        self.tipPercentageCaptionLabel.center.y += 150
        self.tipPercentageLabel.center.y += 150
        self.tipSlider.center.y += 150
        self.topView.center.y += 150
    }
    func animateHideOnEmptyInput() {
        UIView.animateWithDuration(0.2, animations: {
            self.bottomView.center.y += 150
            self.tipPercentageCaptionLabel.center.y += 150
            self.tipPercentageLabel.center.y += 150
            self.tipSlider.center.y += 150
            self.topView.center.y += 150
            }, completion: nil)
    }
    func animateShowOnInput() {
        UIView.animateWithDuration(0.2, animations: {
            self.bottomView.center.y -= 150
            self.tipPercentageCaptionLabel.center.y -= 150
            self.tipPercentageLabel.center.y -= 150
            self.tipSlider.center.y -= 150
            self.topView.center.y -= 150
            }, completion: nil)
    }
    
    
    var isUp = true
    func animateSliderCaption() {
        if tipSlider.value > tipSlider.maximumValue*0.56 && isUp {
            isUp = false
            UIView.animateWithDuration(0.3, animations: {
                self.tipPercentageCaptionLabel.center.y += 8
                }, completion: nil)
        }
        if tipSlider.value < tipSlider.maximumValue*0.56 && !isUp {
            isUp = true
            UIView.animateWithDuration(0.3, animations: {
                self.tipPercentageCaptionLabel.center.y -= 8
                }, completion: nil)
        }
    }
    
    
    var isViewHidden = true
    func updateValues() -> (Double, Double) {
        
        let possibleBillAmount = Double(billField.text!)
        let tipPercentage = round(100*tipSlider.value) / 100
        tipPercentageLabel.text = "\(Int(tipPercentage*100))%"
        
        if let billAmount = possibleBillAmount {
            let tipAmount = billAmount * Double(tipPercentage)
            let totalAmount = billAmount + tipAmount
            
            if isViewHidden {
                animateShowOnInput()
                isViewHidden = false
            }
            
            tipLabel.text = String(format: "$%.2f", tipAmount)
            totalLabel.text = String(format: "$%.2f", totalAmount)
            cashLabel.text = String(format: "$%.2f", ceil(totalAmount))
            
            return (billAmount, Double(tipPercentage))
        }
        else {
            animateHideOnEmptyInput()
            isViewHidden = true
            
            tipLabel.text = "$0.00"
            totalLabel.text = "$0.00"
            cashLabel.text = "$0.00"
            
            return (0,0)
        }
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make keyboard automatically show when application launches
        billField.delegate = self
        billField.becomeFirstResponder()
        
        let possibleDefaultTipPercentage = NSUserDefaults.standardUserDefaults().stringForKey("default_tip_percentage")
        if let defaultTipPercentage = possibleDefaultTipPercentage {
            let dtp_f = Float(defaultTipPercentage)!
            tipSlider?.setValue(dtp_f, animated: true)
            tipPercentageLabel.text = "\(Int(dtp_f*100))%"
            animateSliderCaption()
        }
        
        let possibleDisappearDate = NSUserDefaults.standardUserDefaults().objectForKey("disappear_date")
        if let disappearDate = possibleDisappearDate {
            
            //get the rough number of seconds since calculator disappeared
            let elapsedTime = Int(NSDate().timeIntervalSinceDate(disappearDate as! NSDate))
            let deleteAfter = 5   //5 minutes
            
            if elapsedTime < deleteAfter {
                billField.text = "\(NSUserDefaults.standardUserDefaults().doubleForKey("bill_amount"))"
                updateValues()
                if isViewHidden {
                    animateShowOnInput()
                }
            }
        }
        initialHiding() //bad hack (fix later)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let disappearDate = NSDate()
        NSUserDefaults.standardUserDefaults().setObject(disappearDate, forKey: "disappear_date")
    }
    
    
    
    

    //MARK: actions
    
    @IBAction func onBillEditingChanged(sender: AnyObject) {
        let (billAmount, tipPercentage) = updateValues()
        NSUserDefaults.standardUserDefaults().setDouble(billAmount, forKey: "bill_amount")
        NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "default_tip_percentage")
    }
    
    @IBAction func onTap(sender: AnyObject) {
        if !isViewHidden {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func onSliderValueChanged(sender: AnyObject) {
        let (billAmount, tipPercentage) = updateValues()
        NSUserDefaults.standardUserDefaults().setDouble(billAmount, forKey: "bill_amount")
        NSUserDefaults.standardUserDefaults().setDouble(tipPercentage, forKey: "default_tip_percentage")
        animateSliderCaption()
    }
    
}

