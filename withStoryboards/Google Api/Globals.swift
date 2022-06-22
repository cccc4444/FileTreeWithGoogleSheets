//
//  Globals.swift
//  withStoryboards
//
//  Created by Danylo Kushlianskyi on 20.06.2022.
//


import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import GTMSessionFetcher

class Globals: NSObject {

    let YOUR_SHEET_ID = "18Qct5pPDkZyl9NZSB1NGqMjn7SZ-RsTW5iN_Ph4UtdM"
    let YOUR_API_KEY = "AIzaSyAJmdc-_-noDHfzQ1Jg4WEaDdM5cytnvMI"
    let YOUR_CLIENT_ID = "378760259705-gjtuip633q414estnhnsqumkc6in7bjj.apps.googleusercontent.com"

    var gUser = GIDGoogleUser()
    let sheetService = GTLRSheetsService()

    override init() {
    }

    static var shared = Globals()
}
