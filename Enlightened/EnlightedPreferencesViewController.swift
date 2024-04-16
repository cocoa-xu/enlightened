//
//  EnlightedPreferencesViewController.swift
//  Enlightened
//
//  Created by Cocoa on 16/04/2024.
//

import Foundation
import Cocoa

class EnlightedPreferencesViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var tokenTextField: NSTextField!
    @IBOutlet weak var updateFreqTextField: NSTextField!
    @IBOutlet weak var updateFreqStepper: NSStepper!
    @IBOutlet weak var updateFreqComboBox: NSComboBox!

    override func viewDidLoad() {
        self.tokenTextField.target = self
        self.tokenTextField.isEditable = true
        self.tokenTextField.focusRingType = .none
        self.tokenTextField.delegate = self
        
        self.updateFreqTextField.target = self
        self.updateFreqTextField.isEditable = true
        self.updateFreqTextField.focusRingType = .none
        self.updateFreqTextField.delegate = self
        
        self.updateFreqStepper.increment = 1
        self.updateFreqStepper.maxValue = 999999999
        self.updateFreqStepper.minValue = 1
        self.updateFreqStepper.valueWraps = true
        self.updateFreqStepper.target = self
//        self.updateFreqStepper.action = #selector(ZerotierStatusPreferencesViewController.stepperValueChanged)
        
        self.updateFreqComboBox.target = self
//        self.updateFreqComboBox.action = #selector(ZerotierStatusPreferencesViewController.comboBoxValueChanged)
    }
    
    @objc func stepperValueChanged() {
        if self.updateFreqStepper.integerValue >= 1 {
            let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
//            appDelegate.updateFreqValue = UInt(self.updateFreqStepper.integerValue)
        }
    }
    
    @objc func comboBoxValueChanged() {
        switch self.updateFreqComboBox.indexOfSelectedItem {
        case 0...3:
            let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
//            appDelegate.updateFreqTimeUnit = UInt(self.updateFreqComboBox.indexOfSelectedItem)
        default:
            _ = 1
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
            if control == self.tokenTextField! {
//                appDelegate.zerotierAPIKey = tokenTextField.stringValue
            } else {
                let userInput = self.updateFreqTextField!.integerValue
                if userInput >= 1 {
//                    appDelegate.updateFreqValue = UInt(userInput)
//                    self.updateFreqStepper.floatValue = Float(userInput)
                }
            }
            return true
        }

        return false
    }
}
