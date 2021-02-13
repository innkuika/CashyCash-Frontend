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
    
}
