//
//  ViewController.swift
//  ContactsTool
//
//  Created by Ignacio Inglese on 10/28/14.
//  Copyright (c) 2014 posto7. All rights reserved.
//

import UIKit
import AddressBook

class ViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addContacts() {
        
        showLoading("Adding contacts...")
        
        let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue();
        
        let auth = ABAddressBookGetAuthorizationStatus()
        switch auth {
        case .Denied, .Restricted:
            showError()
        case .NotDetermined, .Authorized:
            ABAddressBookRequestAccessWithCompletion(addressBook) {
                (granted: Bool, err: CFError!) -> Void in
                if granted {
                    self.doAddContacts(addressBook)
                }
                else {
                    self.showError()
                }
            }
        }
        
    }
    
    @IBAction func removeContacts() {
        
        showLoading("Removing contacts...")
        
        let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue();
        
        let auth = ABAddressBookGetAuthorizationStatus()
        switch auth {
        case .Denied, .Restricted:
            showError()
        case .NotDetermined, .Authorized:
            ABAddressBookRequestAccessWithCompletion(addressBook) {
                (granted: Bool, err: CFError!) -> Void in
                if granted {
                    self.doRemoveContacts(addressBook)
                }
                else {
                    self.showError()
                }
            }
        }
    }
    
    func doAddContacts(addressBook: ABAddressBook) {
        
        let contactCount = textField.text.toInt()
        
        if contactCount <= 0 {
            hideLoading()
            UIAlertView(title: "Error", message: "Please select the amount of contacts to add", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            () -> Void in
            for (var i = 0 ; i < contactCount ; ++i) {
                let record: ABRecord = ABPersonCreate().takeRetainedValue()
                let email: ABMutableMultiValue = ABMultiValueCreateMutable(NSNumber(integer: kABStringPropertyType).unsignedIntValue).takeRetainedValue()
                ABMultiValueAddValueAndLabel(email, "\(i)@\(i)foo.com", kABHomeLabel, nil)
                let phone: ABMutableMultiValue = ABMultiValueCreateMutable(NSNumber(integer: kABMultiStringPropertyType).unsignedIntValue).takeRetainedValue()
                ABMultiValueAddValueAndLabel(phone, "\(self.randomDecimalNumber())\(self.randomDecimalNumber()) (\(self.randomDecimalNumber())\(self.randomDecimalNumber())) \(self.randomDecimalNumber())\(self.randomDecimalNumber())\(self.randomDecimalNumber())\(self.randomDecimalNumber()) \(self.randomDecimalNumber())\(self.randomDecimalNumber())\(self.randomDecimalNumber())\(self.randomDecimalNumber())", kABPersonPhoneMobileLabel, nil)
                
                ABRecordSetValue(record, kABPersonFirstNameProperty, "Test Name \(i)", nil)
                ABRecordSetValue(record, kABPersonLastNameProperty, "Last Name \(i)", nil)
                ABRecordSetValue(record, kABPersonEmailProperty, email, nil)
                ABRecordSetValue(record, kABPersonPhoneProperty, phone, nil)
                
                ABAddressBookAddRecord(addressBook, record, nil)
            }
            
            ABAddressBookSave(addressBook, nil)
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                
                self.hideLoading()
                UIAlertView(title: "Success", message: "Contacts added!", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Yay!").show()
            }
        }
    }
    
    func doRemoveContacts(addressBook: ABAddressBook) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            () -> Void in
        
            let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray as Array
            let peopleCount = ABAddressBookGetPersonCount(addressBook)
            for (var i = 0 ; i < peopleCount ; ++i) {
                let ref: AnyObject = allPeople[i]
                let firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty).takeRetainedValue() as NSString
                if firstName.rangeOfString("Test Name").location != NSNotFound {
                    println("Deleting contact '\(firstName)'")
                    ABAddressBookRemoveRecord(addressBook, ref, nil)
                }
            }
            ABAddressBookSave(addressBook, nil)
            
            ABAddressBookSave(addressBook, nil)
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                
                self.hideLoading()
                UIAlertView(title: "Success", message: "Contacts removed!", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Yay!").show()
            }
        }
    }
    
    func showError() {
        hideLoading()
        
        UIAlertView(title: "Error", message: "Address book access not authorized", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
    }
    
    func randomDecimalNumber() -> Int {
        return Int(arc4random()) % 10
    }
    
    func showLoading(text: String) {
        loadingLabel.text = text
        loadingView.hidden = false
    }
    
    func hideLoading() {
        loadingView.hidden = true
    }


}

