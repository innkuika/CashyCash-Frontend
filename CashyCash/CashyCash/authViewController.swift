//
//  authViewController.swift
//  CashyCash
//
//  Created by Jessica Wu on 1/15/21.
//

import Foundation
import UIKit

class authViewController : UIViewController, PinTexFieldDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        code0.delegate = self
        code1.delegate = self
        code2.delegate = self
        code3.delegate = self
        code4.delegate = self
        code5.delegate = self
        
        fieldArray = [code0, code1, code2, code3, code4, code5]
        nextFieldDictionary = [code0: code1,
                               code1: code2,
                               code2: code3,
                               code3: code4,
                               code4: code5]
        previousFieldDictionary = [code1: code0,
                                   code2: code1,
                                   code3: code2,
                                   code4: code3,
                                   code5: code4]
        
        fieldArray.map { $0.addTarget(self, action: #selector(authViewController.textFieldDidChange(_:)),
                                      for: .editingChanged)
                         $0.textContentType = .oneTimeCode
        }
        
        code0.becomeFirstResponder()
        
        guard let unwrappedNumber = phoneNumber else { return }
        instructionMessageOutlet.text = "Enter the code sent to \(unwrappedNumber)"
        errorMessageOutlet.text = ""
      
    }
    var phoneNumber: String? = nil
    var nextFieldDictionary: [UITextField: UITextField] = [:]
    var previousFieldDictionary: [UITextField: UITextField] = [:]
    var fieldArray: [UITextField] = []
    var authToken: String?
    
    @IBOutlet weak var code0: PinTextField!
    @IBOutlet weak var code1: PinTextField!
    @IBOutlet weak var code2: PinTextField!
    @IBOutlet weak var code3: PinTextField!
    @IBOutlet weak var code4: PinTextField!
    @IBOutlet weak var code5: PinTextField!
    
    @IBOutlet weak var instructionMessageOutlet: UILabel!
    @IBOutlet weak var errorMessageOutlet: UILabel!
    
    // MARK: -pinTextField protocol implementation
    func didPressBackspace(textField : PinTextField){
        guard let previousField = previousFieldDictionary[textField] else {
            return
        }
        previousField.becomeFirstResponder()
    }
    
    
    @IBAction func resendButtonPressed(_ sender: Any) {
        // try to send send verification code
        guard let validPhoneNumber = phoneNumber else { return }
        Api.sendVerificationCode(phoneNumber: validPhoneNumber) { response, error in
            if error != nil{
                self.errorMessageOutlet.text = error?.message
            }else {
                self.codeIsNotValid(errorMessage: "We've resent the code")
            }
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("text field did change")
        guard let textLength = textField.text?.count else { return }
        guard let nextField = nextFieldDictionary[textField] else {
            
            // user has entered the last digit
            if textLength == 1 {
                codeEntered()
                
            }
            else if textLength > 1{
                guard let currentDigit = textField.text?.prefix(1) else { return }
                textField.text = String(currentDigit)
            }
            return
        }
        
        if textLength == 1 {
            // move the cursor to the next field
            nextField.becomeFirstResponder()
            codeEntered()
        }
        else if textLength > 1{
            guard let currentDigit = textField.text?.prefix(1) else { return }
            textField.text = String(currentDigit)
            nextField.becomeFirstResponder()
        }
    }
    
    func codeEntered(){
        guard let validPhoneNumber = phoneNumber else { return }
        
        // get the latest code
        let code = fieldArray.reduce(""){
            let tmpDigit = ($1.text?.prefix(1)) ?? ""
            return $0 + tmpDigit
      }
        print(code)
        
        if code.count == 6{
            // dismiss keyboard
            view.endEditing(true)

            // go check the code
            Api.verifyCode(phoneNumber: validPhoneNumber, code: code) { response, error in
                // update authentication token
                self.authToken = response?["auth_token"] as? String
                if error == nil {
                    self.codeIsValid()
                } else {
                    self.codeIsNotValid(errorMessage: error?.message ?? "Please try again")
                }
            }
        }
    }
    
    func codeIsNotValid(errorMessage: String){
        // displays error message
        errorMessageOutlet.text = errorMessage
    }
    
    func codeIsValid(){
        // store phone number
        Storage.phoneNumberInE164 = phoneNumber
        
        // store auth token
        Storage.authToken = authToken
        
        // navigate to homeViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeViewController = storyboard.instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController else {
            assertionFailure("couldn't find homeViewController")
            return
        }
        
        navigationController?.pushViewController(homeViewController, animated: true)
        
    }

}
