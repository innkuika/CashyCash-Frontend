//
//  detailViewController.swift
//  CashyCash
//
//  Created by Jessica Wu on 2/11/21.
//

import Foundation
import UIKit

class detailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    var wallet: Wallet? = nil
    var accountIndex: Int? = nil

    @IBOutlet weak var accountNameLabelOutlet: UILabel!
    @IBOutlet weak var totalAmountLabelOutlet: UILabel!
    
    // popup variable outlets
    var popup: UIView = UIView()
    var accountNameTextField: UITextField = UITextField()
    var transferAmountTextField: UITextField = UITextField()
    var errorMsgLabel: UILabel = UILabel()
    typealias popupButtonPressedHandler = (_ sender:UIButton) -> Void
    
    override func viewDidLoad() {
        // do init here
        guard let wallet = wallet else { return }
        guard let accountIndex = accountIndex else { return }
        let account = wallet.accounts[accountIndex]
        accountNameLabelOutlet.text = account.name
        totalAmountLabelOutlet.text = "$\(account.amount)"
    }

    
    
    @IBAction func depositButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Deposit", message: "Please enter the amount you would like to deposit.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = UIKeyboardType.numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            guard let wallet = wallet else { return }
            guard let accountIndex = accountIndex else { return }
            guard let textFields = alert.textFields else { return }
            let input = textFields[0].text ?? ""
            if let amount = Double(input) {
                Api.deposit(wallet: wallet, toAccountAt: accountIndex, amount: amount, completion: { response, error in
                    totalAmountLabelOutlet.text = "$\(wallet.accounts[accountIndex].amount)"
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func withdrawButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Withdraw", message: "Please enter the amount you would like to withdraw.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = UIKeyboardType.numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            guard let wallet = wallet else { return }
            guard let accountIndex = accountIndex else { return }
            guard let textFields = alert.textFields else { return }
            let input = textFields[0].text ?? ""
            if let amount = Double(input) {
                Api.withdraw(wallet: wallet, fromAccountAt: accountIndex, amount: min(amount, wallet.accounts[accountIndex].amount), completion: { response, error in
                    totalAmountLabelOutlet.text = "$\(wallet.accounts[accountIndex].amount)"
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func transferButtonPressed(_ sender: Any) {
        loadPopupToController(title: "Transfer", buttonPressHandler: #selector(self.popupButtonPressed))
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard let wallet = wallet else { return }
        guard let accountIndex = accountIndex else { return }
        Api.removeAccount(wallet: wallet, removeAccountat: accountIndex, completion: { response, error in return })
        navigationController?.popViewController(animated: true)
    }
    
    func loadPopupToController(title: String, buttonPressHandler: Selector) {
        let customViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: self.view.frame.height - 600)
        popup = UIView(frame: customViewFrame)
        popup.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        popup.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 3)
        popup.layer.cornerRadius = 40
        // make popup visible
        popup.isHidden = false
        // add shadow
        popup.layer.shadowColor = UIColor.gray.cgColor
        popup.layer.shadowRadius = 5
        popup.layer.shadowOpacity = 1
        popup.layer.shadowOffset = .zero
        
        
        // create button and add to popup view
        let okayButtonFrame = CGRect(x: 40, y: 100, width: 80, height: 50)
        let okayButton = UIButton(frame: okayButtonFrame )
        okayButton.setTitle("ok", for: .normal)
        okayButton.backgroundColor = UIColor(red: 166/255, green: 221/255, blue: 1, alpha: 1.0)
        okayButton.addTarget(self, action: buttonPressHandler, for:.touchUpInside)
        okayButton.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 4 / 5)
        okayButton.layer.cornerRadius = 20
        popup.addSubview(okayButton)
        

        // create account name textfield and add to popup view
        let accountNameTextFieldFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        accountNameTextField = UITextField(frame: accountNameTextFieldFrame)
        accountNameTextField.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 0.3)
        accountNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        accountNameTextField.delegate = self
        
        let thePicker = UIPickerView()
        thePicker.delegate = self
        accountNameTextField.inputView = thePicker
        popup.addSubview(accountNameTextField)
        
        
        // create transfer amount textfield and add to popup view
        let transferAmountTextFieldFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        transferAmountTextField = UITextField(frame: transferAmountTextFieldFrame)
        transferAmountTextField.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 0.5)
        transferAmountTextField.borderStyle = UITextField.BorderStyle.roundedRect
        transferAmountTextField.keyboardType = UIKeyboardType.numberPad
        transferAmountTextField.delegate = self
        popup.addSubview(transferAmountTextField)
        
        // create error message label and add to popup view
        let errorMsgLabelFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        errorMsgLabel = UILabel(frame: errorMsgLabelFrame)
        errorMsgLabel.textColor = UIColor(red: 255/255, green: 122/255, blue: 98/255, alpha: 1)
        errorMsgLabel.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 0.65)
        popup.addSubview(errorMsgLabel)
        
        // create popup title label and add to popup view
        let titleLabelFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        let titleLabel = UILabel(frame: titleLabelFrame)
        titleLabel.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 0.15)
        titleLabel.text = title
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        popup.addSubview(titleLabel)
        
        // add popup into view as a subview
        self.view.addSubview(popup)
    }
    
    @objc func popupButtonPressed(sender:UIButton) {
        print("button pressed")
        guard let wallet = wallet else { return }
        guard let accountIndex = accountIndex else { return }
        guard let accountPicker = accountNameTextField.inputView as? UIPickerView else { return }
        let input = transferAmountTextField.text ?? ""
        if let amount = Double(input) {
            if amount > wallet.accounts[accountIndex].amount {
                errorMsgLabel.text = "Transfer amount too large"
            } else {
                Api.transfer(wallet: wallet, fromAccountAt: accountIndex, toAccountAt: accountPicker.selectedRow(inComponent: 0), amount: amount, completion: { response, error in return })
                popup.removeFromSuperview()
                totalAmountLabelOutlet.text = "$\(wallet.accounts[accountIndex].amount)"
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return wallet?.accounts.count ?? 0
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let accountNamesArr = wallet?.accounts.map{ $0.name }
        return accountNamesArr?[row]
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(wallet?.accounts.map{ $0.name })
        let accountNamesArr = wallet?.accounts.map{ $0.name }
        accountNameTextField.text = accountNamesArr?[row]
    }
    
     func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
   
    
}
