//
//  HomeViewController.swift
//  CashyCash
//
//  Created by Jessica Wu on 1/22/21.
//

import Foundation
import UIKit

struct User: Decodable {
    let name: String
    
}

class HomeViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
   
    @IBOutlet weak var nameTextfieldOutlet: UITextField!
    @IBOutlet weak var accountDetailOutlet: UITableView!
    @IBOutlet weak var totalAmountOutlet: UILabel!
    var wallet: Wallet?
    var popup: UIView = UIView()
    var accountNameTextField: UITextField = UITextField()
    var errorMsgLabel: UILabel = UILabel()
    var greyRect: UIView = UIView()
    
    
    override func viewDidLoad() {

        // disable back button
        navigationItem.hidesBackButton = true
        
        // set table view data source
        accountDetailOutlet.dataSource = self
        accountDetailOutlet.delegate = self
        
        
        self.nameTextfieldOutlet.delegate = self

        // get user info
        Api.user() { response, error in
            guard let user = response?["user"] as? [String: Any] else{
                assertionFailure("No user info")
                return
            }
            
            // get user name, if no user name is set, set name as phone number
            let name = user["name"] as? String ?? Storage.phoneNumberInE164
            
            // if user name is empty string, put phone number
            if !(name?.isEmpty ?? true){
                self.nameTextfieldOutlet.text = name
            }else{
                self.nameTextfieldOutlet.text = Storage.phoneNumberInE164
            }
            
            guard let unwrappedResponse = response else{
                return
            }
            
            // setup account detail table view
            self.wallet = Wallet.init(data: unwrappedResponse, ifGenerateAccounts: false)
            self.accountDetailOutlet.reloadData()
            
            // show total amount
            let totalAmount = String(format: "%.2f", self.wallet?.totalAmount ?? 0)
            self.totalAmountOutlet.text = "Total Amount: \(totalAmount)"
        }
    }
    
    // deselect the cell
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = accountDetailOutlet.indexPathForSelectedRow{
            accountDetailOutlet.deselectRow(at: selectedIndexPath, animated: animated)
        }
        accountDetailOutlet.reloadData()
    }
    
    func loadPopupToController() {
        let greyRectFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        greyRect = UIView(frame: greyRectFrame)
        greyRect.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.view.addSubview(greyRect)
        let customViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.9, height: self.view.frame.height * 0.3)
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
        okayButton.addTarget(self, action: #selector(self.didPressButtonFromCustomView), for:.touchUpInside)
        okayButton.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 4 / 5)
        okayButton.layer.cornerRadius = 20
        popup.addSubview(okayButton)
        
        // create textfield and add to popup view
        let accountNameTextFieldFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        accountNameTextField = UITextField(frame: accountNameTextFieldFrame)
        accountNameTextField.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 0.4)
        accountNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
      
        let accString = placeAccountNumber()
        accountNameTextField.placeholder = accString
        
        popup.addSubview(accountNameTextField)
        
        // create error message label and add to popup view
        let errorMsgLabelFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        errorMsgLabel = UILabel(frame: errorMsgLabelFrame)
        errorMsgLabel.textColor = UIColor(red: 255/255, green: 122/255, blue: 98/255, alpha: 1)
        errorMsgLabel.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 3 / 5)
        popup.addSubview(errorMsgLabel)
        
        // create popup title label and add to popup view
        let titleLabelFrame = CGRect(x: 5, y: 5, width: popup.frame.size.width - 60, height: 40)
        let titleLabel = UILabel(frame: titleLabelFrame)
        titleLabel.center = CGPoint(x: popup.frame.size.width / 2, y: popup.frame.size.height * 0.2)
        titleLabel.text = "Please enter account name"
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        popup.addSubview(titleLabel)
        
        // add popup into view as a subview
        self.view.addSubview(popup)
    }
    
    func placeAccountNumber() -> String{
        guard let unwrappedWallet = wallet else {
            return ""
        }
        
        var suggestedName = "Account \(String(unwrappedWallet.accounts.count + 1))"
                let accountNames = Set(unwrappedWallet.accounts.map({ account in
                    account.name
                }))
                if accountNames.contains(suggestedName) {
                    var possibleAccountNames = Set((1..<(accountNames.count + 1)).map({ num in "Account \(num)" }))
                    possibleAccountNames.subtract(accountNames)
                    suggestedName = possibleAccountNames[possibleAccountNames.index(possibleAccountNames.startIndex, offsetBy: 0)]
                }
               return suggestedName
    }
    
    @objc func didPressButtonFromCustomView(sender:UIButton) {
        guard let wallet = wallet else {
            return
        }
        
        // unwrap account name
        guard var accountName = accountNameTextField.text else {
            return
        }
        guard let unwrapped = accountNameTextField.placeholder else {
            return
        }
        // if account name is an empty string, display error message
        if accountName == "" {
            accountName = unwrapped
        }
        
        // if the account name has been taken, display an error message
        let accountNamesArr = wallet.accounts.map{ $0.name }
        if accountNamesArr.contains(accountName) {
            errorMsgLabel.text = "Duplicate account name"
            return
        }
        // add account
        Api.addNewAccount(wallet: wallet, newAccountName: accountName) {
            response, error in
            
            self.view.endEditing(true)
            self.popup.isHidden = true
            self.greyRect.isHidden = true
            self.accountDetailOutlet.reloadData()
        }
        

        }
    
    // MARK: -UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0)
        return wallet?.accounts.count ?? 0
    }
    // MARK: -UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell") ?? UITableViewCell(style: .default, reuseIdentifier: "accountCell")

        let account = wallet?.accounts[indexPath.row]
        
        let accountName = account?.name ?? "account name not found"
        let accountAmount = account?.amount ?? 0
        cell.textLabel?.text = "\(accountName): " + String(format: "%.2f", accountAmount)
        cell.imageView?.image = UIImage(systemName: "dollarsign.circle.fill")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "detailViewController") as? detailViewController else {
            assertionFailure("detailViewController not found")
            return
        }
        detailViewController.wallet = wallet
        detailViewController.accountIndex = indexPath.row
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        // navigate to viewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "viewController") as? ViewController else {
            assertionFailure("couldn't find viewController")
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        loadPopupToController()
    }
    @IBAction func nameTextfieldEndAction(_ sender: Any) {
        Api.setName(name: nameTextfieldOutlet.text ?? ""){ response, error in
            print("New name set")
        }
        if nameTextfieldOutlet.text?.isEmpty ?? true {
            nameTextfieldOutlet.text = Storage.phoneNumberInE164
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
