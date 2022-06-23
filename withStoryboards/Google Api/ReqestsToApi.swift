//
//  ReqestsToApi.swift
//  withStoryboards
//
//  Created by Danylo Kushlianskyi on 20.06.2022.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import GTMSessionFetcher
import Toast_Swift

var numOfRowInSheets: Int = 37
var range = "Sheet1!A1:D37"
func defineRangeForSaving() -> String{
    let range = "Sheet1!A\(numOfRowInSheets):D" + String(numOfRowInSheets)
    return range
}
func updateRange(){
    range = "Sheet1!A1:D\(numOfRowInSheets)"
}

class RequestsToSheets {
    
    var mainViewController = ViewController()
    
    func signIn(self: UIViewController){
        let signInConfig = GIDConfiguration(clientID: Globals.shared.YOUR_CLIENT_ID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else {
//                self.view.makeToast("error 1", duration: 2.0, position: .center)
                return
            }

            // If sign in succeeded, display the app's main content View.
            guard
                let user = user
            else {
                self.view.makeToast("error 2", duration: 2.0, position: .bottom)
                return
            }

            // Your user is signed in!
            Globals.shared.gUser = user
            Globals.shared.sheetService.authorizer = Globals.shared.gUser.authentication.fetcherAuthorizer()
            print("logged in: \(user.profile?.name ?? "")")
            self.view.makeToast("logged in: \(user.profile?.name ?? "")", duration: 2.0, position: .center)
            self.view.makeToast("Add your account to the scope", duration: 3.0, position: .bottom)

        }
    }
    
    func signOut(self: UIViewController){
        GIDSignIn.sharedInstance.signOut()
        print("logged out")
        self.view.makeToast("Successfully signed out", duration: 2.0, position: .bottom)
    }
    
    func addScope(self: UIViewController){
        let newScope = kGTLRAuthScopeSheetsSpreadsheets
        let grantedScopes = Globals.shared.gUser.grantedScopes

        if grantedScopes == nil || !grantedScopes!.contains(newScope) {
            self.view.makeToast("Scope is not present", duration: 2.0, position: .bottom)

            // Request additional scope.
            let additionalScopes = [newScope]
            GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: self) { user, error in
                guard error == nil else {
                    self.view.makeToast("error 3", duration: 2.0, position: .bottom)
                    return
                }
                guard let user = user else {
                    self.view.makeToast("error 4", duration: 2.0, position: .bottom)
                    return
                }

                Globals.shared.gUser = user
                Globals.shared.sheetService.authorizer = Globals.shared.gUser.authentication.fetcherAuthorizer()

                // Check if the user granted access to the scopes you requested.
                let grantedScopes = Globals.shared.gUser.grantedScopes
                if grantedScopes!.contains(newScope) {
                    self.view.makeToast("Scope added, swipe down to refresh", duration: 2.0, position: .bottom)
                }
            }
        } else {
            self.view.makeToast("Scope is already present", duration: 2.0, position: .bottom)       }
    }
    
    func read(){
        updateRange()
        print(range)
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: Globals.shared.YOUR_SHEET_ID, range: range)
        Globals.shared.sheetService.executeQuery(query) { (_: GTLRServiceTicket, result: Any?, error: Error?) in
            if let error = error {
                print("Error", error.localizedDescription)
                debugPrint(error.localizedDescription)
            } else {
                let data = result as? GTLRSheets_ValueRange
                let rows = data?.values as? [[String]] ?? [[""]]
                for row in rows {
                    if row[1] == "" && !FilesList.allFilesInstance.rootEntities.contains(row){
                        FilesList.allFilesInstance.rootEntities.append(row)
                    }
                    else if row[1] != "" && !FilesList.allFilesInstance.nestedEntities.contains(row){
                        FilesList.allFilesInstance.nestedEntities.append(row)
                    }
                    
                   
                    
                }
                FilesList.allFilesInstance.arr = rows
                print("success")
//                print("Root elements: \(FilesList.allFilesInstance.rootEntities)")
//                print("Nested elements: \(FilesList.allFilesInstance.nestedEntities)")
            }
        }
        
    }
    
    func write(self: UIViewController, primary: String, parent: String, type: String, name: String){
        numOfRowInSheets += 1
        updateRange()
        
        
        let valueRange = GTLRSheets_ValueRange(json: [
            "majorDimension": "ROWS",
            "range": defineRangeForSaving(),
            "values": [
                [
                    primary, parent, type, name
                ],
            ],
        ])
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: Globals.shared.YOUR_SHEET_ID, range: defineRangeForSaving())
        query.valueInputOption = "USER_ENTERED"
        query.includeValuesInResponse = true

        Globals.shared.sheetService.executeQuery(query) { (_: GTLRServiceTicket, result: Any?, error: Error?) in
            if let error = error {
                print("Error", error.localizedDescription)
                self.view.makeToast(error.localizedDescription)
            } else {
                let data = result as? GTLRSheets_UpdateValuesResponse
                let rows = data?.updatedData?.values as? [[String]] ?? [[""]]
                for row in rows {
                    print("row: ", row)
                    self.view.makeToast("value \(row.first ?? "") wrote in \(defineRangeForSaving())")
                }
                print("success")
            }
        }
        
        
        
    }
    
    static var requestsInstance = RequestsToSheets()
}
