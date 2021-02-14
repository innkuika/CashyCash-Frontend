## Your Name | Student ID 
* Jessica Wu |  918374404
* Manprit Heer | 912839204
* Donald Lieu | 916113230
* Jessica Ma | 915345025
* Roberto Lozano | 914294300


## Directly show wallet
* Check if auth token exists in `sceneDelegate`, if so, navigate to `homeView` directly 

## Account view
* Used `UILabel` to display account name and amount
* Used `UIButton` to implement done button
  * goes back to homeView when pressed
* Used `UIButton` and related Api functions to implement and saved updated data to server
  * Deposit
  * Withdraw
  * Transfer
   ** In order to ensure that the user cannot touch outside of the custom pop-up, we added another subview behind the pop-up, whose UserInteractionEnabled functionality was set to false. This gray rectangle subview will then pop off along with the pop-up view once it is dismissed. This same gray view is utilized for the "Create Account" pop-up so that the user cannot click on any other buttons in the parent view.
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

  
  
