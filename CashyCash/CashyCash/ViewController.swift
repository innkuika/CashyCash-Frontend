//
//  ViewController.swift
//  CashyCash
//
//  Created by Jessica Wu on 1/13/21.
//

import UIKit
import PhoneNumberKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable back button
        navigationItem.hidesBackButton = true
        
        phoneNumberTextFieldOutlet.withFlag = true
        phoneNumberTextFieldOutlet.withExamplePlaceholder = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        phoneNumberTextFieldOutlet.textContentType = .telephoneNumber
        phoneNumberTextFieldOutlet.autocorrectionType = .yes
        
        // init the text field with stored phone number
        phoneNumberTextFieldOutlet.text = Storage.phoneNumberInE164
    }
    
    
    @IBOutlet weak var phoneNumberTextFieldOutlet: PhoneNumberTextField!
    @IBOutlet weak var errorMessageOutlet: UILabel!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    let phoneNumberKit = PhoneNumberKit()
    
    @IBAction func textFieldFormatter(_ sender: PhoneNumberTextField) {
        let hasPrefix = phoneNumberTextFieldOutlet.text?.hasPrefix("+1")
        if hasPrefix == false{
            phoneNumberTextFieldOutlet.text = "+1"
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let phoneNumber : String? = phoneNumberTextFieldOutlet.text
        let phoneNumberStored : String?
        
        // tries to parse the phone number, navigates to the next view if success, displays error messages otherwise
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneNumber ?? "")
            phoneNumberStored = phoneNumberKit.format(phoneNumber, toType: .e164)
            
            nextButtonOutlet.tintColor = UIColor(red: 159.0/255.0, green: 216.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            errorMessageOutlet.textColor = UIColor(red: 96.0/255.0, green: 96.0/255.0, blue: 96.0/255.0, alpha: 1.0)
            errorMessageOutlet.text = "Great, we're sending the code to: \(phoneNumberStored ?? "")"
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // if current user is last successfully login user, skip the authView
            if Storage.authToken != nil, (Storage.phoneNumberInE164 ?? "storage unset") == (phoneNumberStored ?? "phoneNumberStored unset"){
                guard let homeViewController = storyboard.instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController else {
                    assertionFailure("couldn't find homeViewController")
                    return
                }
                
                navigationController?.pushViewController(homeViewController, animated: true)
                return 
            }
            
            // navigate to authViewController
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "authViewController") as? authViewController else {
                assertionFailure("couldn't find authViewController")
                return
            }
            
            authViewController.phoneNumber = phoneNumberStored
            
            // try to send send verification code
            guard let validPhoneNumber = phoneNumberStored else { return }
            Api.sendVerificationCode(phoneNumber: validPhoneNumber) { response, error in
                // if the phoneNumber isn't valid, present an alert that asks user to try again
                if error?.code == "invalid_phone_number" {
                    let alert = UIAlertController(title: "Your Number is Invalid", message: "We tried to send a code to \(validPhoneNumber). However, it turned out that it is not valid. Please try another number.", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            
            // if the code was sent successfully, push the authView
            navigationController?.pushViewController(authViewController, animated: true)
            
        }
        catch {
            // if the parse failed, change the textColor and tintColor to red
            nextButtonOutlet.tintColor = UIColor(red: 255.0/255.0, green: 111.0/255.0, blue: 92.0/255.0, alpha: 1.0)
            errorMessageOutlet.textColor = UIColor(red: 255.0/255.0, green: 111.0/255.0, blue: 92.0/255.0, alpha: 1.0)
            if phoneNumber == "+1" || phoneNumber == ""{
                errorMessageOutlet.text = "oops, you haven't entered your number yet"
            }
            else{
                errorMessageOutlet.text = "oops, please enter a valid number"
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

