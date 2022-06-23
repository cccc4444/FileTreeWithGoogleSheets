//
//  FilesList.swift
//  withStoryboards
//
//  Created by Danylo Kushlianskyi on 20.06.2022.
//

import Foundation

class FilesList {
    
    var arr: [[String]] = []
    var rootEntities: [[String]] = []

    var nestedEntities: [[String]] = []

    var dictOfRootWithCildren = [String: [String]]()
    var dictOfInnerWithChildren = [String:[String]]()
    
    static var allFilesInstance = FilesList()
    
}
