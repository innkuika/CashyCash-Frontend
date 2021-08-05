## Directly show wallet
* Check if auth token exists in `sceneDelegate`, if so, navigate to `homeView` directly.  

## Account view
* Used `UILabel` to display account name and amount
* Used `UIButton` to implement Done button
  * The app goes back to homeView when Done is pressed
* Used `UIButton` and related Api functions to implement and saved updated data to server
  * Deposit
  * Withdraw
  * Transfer
  * Delete

## Save the accounts data to server
* Used the provided Api to implement functionality for creating an account, deleting an account, and making transactions (deposits, withdrawals, and transfers)
* See sections below for more detail
  
## Allow account modification
* Allow user to delete an account
  * Calls `Api.removeAccount()` and navigates back to `homeView`
  * Before `homeView` appears, the data inside the accounts table view is reloaded so that the removed account no longer appears inside the table
* Allow user to add an account
  * Implemented a custom popup as a subview and made it visible when needed
  * Suggests account name and prevents duplicate name
  * If the account name "Account n+1" (where n is the number of accounts the user currently has) is taken, then an account name is picked from "Account 1" to "Account n" and displayed as the placeholder of the text field
  * If the text field is left blank, then the suggested account name is used as the name of the new account
  
## Allow transaction
* Implemented a custom popup
  * Used `Picker` for users to select account
  * Used `UITextField` for users to input transfer amount 
* Allow user to deposit to an account
  * Calls `Api.deposit()`
* Allow user to withdraw from an account
  * Calls `Api.withdraw()`
  * If the withdrawal amount exceeds the current balance, simply withdraw the current balance
* Allow user to make transfer from one account to another
  * Calls `Api.transfer()`
  * If the transfer amount exceeds the current balance, do not complete the transfer and instead display an error message inside a label

## Implementation Details
In order to ensure that the user cannot touch outside of the custom pop-up, we added another subview behind the pop-up, whose UserInteractionEnabled functionality was set to false. This gray rectangle subview will then pop off along with the pop-up view once it is dismissed. This same gray view is utilized for the "Create Account" pop-up so that the user cannot click on any other buttons in the parent view.

If the user does not insert an explicit name or clicks enter with an empty textfield, then a placeholder account name is needed for the new account. To account for any missing numbers within the automatic account name placeholders, we implemented code with the use of the higher order function ".map" and subtracted the existing names from the pool of possible numbers, so that a random number from the pool of possibilities was chosen and applied to the suggested name. 
  
