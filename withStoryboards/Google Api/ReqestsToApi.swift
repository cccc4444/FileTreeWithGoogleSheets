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
        
        let range = "Sheet1!A1:D37"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: Globals.shared.YOUR_SHEET_ID, range: range)
        Globals.shared.sheetService.executeQuery(query) { (_: GTLRServiceTicket, result: Any?, error: Error?) in
            if let error = error {
                print("Error", error.localizedDescription)
                debugPrint(error.localizedDescription)
            } else {
                let data = result as? GTLRSheets_ValueRange
                let rows = data?.values as? [[String]] ?? [[""]]
                for row in rows {
                    print(row)
                    if row[1] == "" && !FilesList.allFilesInstance.rootEntities.contains(row[3]){
                        FilesList.allFilesInstance.rootEntities.append(row[3])
                        switch row[2] {
                        case "d":
                            FilesList.allFilesInstance.rootTypes.append("d")
                        default:
                            FilesList.allFilesInstance.rootTypes.append("f")
                        }
                    }
                    
                   
                    
                }
                FilesList.allFilesInstance.arr = rows
                print("success")
                print("All elements: \(FilesList.allFilesInstance.arr)")
                print("Root elements: \(FilesList.allFilesInstance.rootEntities)")
            }
        }
        
    }
    
    func write(){
        
        
    }
    
    static var requestsInstance = RequestsToSheets()
}
