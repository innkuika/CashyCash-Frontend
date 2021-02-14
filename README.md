## Your Name | Student ID 
* Jessica Wu |  918374404
* Manprit Heer | 912839204
* Donald Lieu | 916113230
* Jessica Ma | 915345025
* Roberto Lozano | 


## Directly show wallet
* Check if auth token exist in `sceneDelegate`, if so, navigate to `homeView` directly 

## Account view
* Used `UILabel` to display account name and amount
* Used `UIButton` to implement done button
  * goes back to homeView when pressed
* Used `UIButton` and related Api functions to implement and saved updated data to server
  * Deposit
  * Withdraw
  * Transfer
  * Delete
  
## Allow account modification
* Allow user to delete an account
  * See previous section for detail
* Allow user to add an account
  * Implemented a custom popup as a subview and made it visible when needed
  * Suggests account name and prevents duplicate name
  
## Allow transaction
* Implemented a custom popup
  * Used `Picker` for users to select account
  * Used `UITextField` for users to input transfer amount 

  
  
