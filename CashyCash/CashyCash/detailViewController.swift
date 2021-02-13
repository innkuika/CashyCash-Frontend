//
//  detailViewController.swift
//  CashyCash
//
//  Created by Jessica Wu on 2/11/21.
//

import Foundation
import UIKit

class detailViewController: UIViewController{
    var accountName: String? = nil
    var totalAmount: Double? = nil
    @IBOutlet weak var accountNameLabelOutlet: UILabel!
    @IBOutlet weak var totalAmountLabelOutlet: UILabel!
    
    var popupView: UIView = UIView()
    var popupTextField: UITextField = UITextField()
    var errorMsgLabel: UILabel = UILabel()

    
    override func viewDidLoad() {
        // do init here
        guard let totalAmount = totalAmount else{
            return
        }
        guard let accountName = accountName else {
            return
        }
        accountNameLabelOutlet.text = accountName
        totalAmountLabelOutlet.text = "$\(totalAmount)"
    }

    
    
    @IBAction func depositButtonPressed(_ sender: Any) {
    }
    
    @IBAction func withdrawButtonPressed(_ sender: Any) {
    }
    
    @IBAction func transferButtonPressed(_ sender: Any) {
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
    }
    
    func loadPopupToController() {
        let customViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: self.view.frame.height - 600)
        popupView = UIView(frame: customViewFrame)
        popupView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        popupView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 3)
        popupView.layer.cornerRadius = 40
        // make popup visible
        popupView.isHidden = false
        // add shadow
        popupView.layer.shadowColor = UIColor.gray.cgColor
        popupView.layer.shadowRadius = 5
        popupView.layer.shadowOpacity = 1
        popupView.layer.shadowOffset = .zero
        
        
        // create button and add to popup view
        let okayButtonFrame = CGRect(x: 40, y: 100, width: 80, height: 50)
        let okayButton = UIButton(frame: okayButtonFrame )
        okayButton.setTitle("ok", for: .normal)
        okayButton.backgroundColor = UIColor(red: 166/255, green: 221/255, blue: 1, alpha: 1.0)
        okayButton.addTarget(self, action: #selector(self.didPressButtonFromCustomView), for:.touchUpInside)
        okayButton.center = CGPoint(x: popupView.frame.size.width / 2, y: popupView.frame.size.height * 4 / 5)
        okayButton.layer.cornerRadius = 20
        popupView.addSubview(okayButton)
        
        // create textfield and add to popup view
        let accountNameTextFieldFrame = CGRect(x: 5, y: 5, width: popupView.frame.size.width - 60, height: 40)
        popupTextField = UITextField(frame: accountNameTextFieldFrame)
        popupTextField.center = CGPoint(x: popupView.frame.size.width / 2, y: popupView.frame.size.height * 0.4)
        popupTextField.borderStyle = UITextField.BorderStyle.roundedRect
        popupView.addSubview(popupTextField)
        
        // create error message label and add to popup view
        let errorMsgLabelFrame = CGRect(x: 5, y: 5, width: popupView.frame.size.width - 60, height: 40)
        errorMsgLabel = UILabel(frame: errorMsgLabelFrame)
        errorMsgLabel.textColor = UIColor(red: 255/255, green: 122/255, blue: 98/255, alpha: 1)
        errorMsgLabel.center = CGPoint(x: popupView.frame.size.width / 2, y: popupView.frame.size.height * 3 / 5)
        popupView.addSubview(errorMsgLabel)
        
        // create popup title label and add to popup view
        let titleLabelFrame = CGRect(x: 5, y: 5, width: popupView.frame.size.width - 60, height: 40)
        let titleLabel = UILabel(frame: titleLabelFrame)
        titleLabel.center = CGPoint(x: popupView.frame.size.width / 2, y: popupView.frame.size.height * 0.2)
        titleLabel.text = "Please enter account name"
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        popupView.addSubview(titleLabel)
        
        // add popup into view as a subview
        self.view.addSubview(popupView)
    }
    
    @objc func didPressButtonFromCustomView(sender:UIButton) {
        print("custom button pressed")
    }
    
}
