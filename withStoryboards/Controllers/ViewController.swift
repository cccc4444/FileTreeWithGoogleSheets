//
//  ViewController.swift
//  withStoryboards
//
//  Created by Danylo Kushlianskyi on 14.06.2022.
//

import UIKit


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    @IBOutlet weak var switchViewButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ProfileBarButton: UIBarButtonItem!
    

    var isListView = true
    
    private let refreshControlForTable = UIRefreshControl()
    private let refreshControlForCollection = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.alpha = 0
        collectionView.alpha = 1
        
        contextMenu()
        signInWithDelay()
        refresherInitialisers()
        
        RequestsToSheets.requestsInstance.read()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.tableView.reloadData()
            self.collectionView.reloadData()
            self.createDicts()
        }
        
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func createDicts(){
        for i in FilesList.allFilesInstance.rootEntities{
            var tempArray = [String]()
            for j in FilesList.allFilesInstance.nestedEntities{
                if i[0] == j[1]{
                    tempArray.append(j[3])
                }
            }
            FilesList.allFilesInstance.dictOfRootWithCildren[i[3]] = tempArray
        }

        for i in FilesList.allFilesInstance.nestedEntities{
            var tempArray = [String]()
            for j in FilesList.allFilesInstance.nestedEntities{
                if i[0] == j[1]{
                    tempArray.append(j[3])
                }
            }
            FilesList.allFilesInstance.dictOfInnerWithChildren[i[3]] = tempArray
        }


        
    }
    
    
    
    private func refresherInitialisers(){
        refreshControlForTable.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        refreshControlForCollection.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.alwaysBounceVertical = true
        tableView.refreshControl = refreshControlForTable
        
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControlForCollection
        
        
        
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {

        
        RequestsToSheets.requestsInstance.read()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.tableView.reloadData()
            self.collectionView.reloadData()
            self.createDicts()
        }
        refreshControlForTable.endRefreshing()
        refreshControlForCollection.endRefreshing()
        
        
    }
    
    
   
    private func signInWithDelay(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            RequestsToSheets.requestsInstance.signIn(self: self)
        }
    }
    
    private func contextMenu(){
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Sign In", image: UIImage(named:"google.png"), handler: {(_) in
                    RequestsToSheets.requestsInstance.signIn(self: self)
                }),
                UIAction(title: "Sign Out", image: UIImage(systemName: "person.crop.circle.badge.xmark"), handler: { (_) in
                    RequestsToSheets.requestsInstance.signOut(self: self)
                }),
                UIAction(title: "Add Scope", image: UIImage(systemName: "plus"), handler: { (_) in
                    RequestsToSheets.requestsInstance.addScope(self: self)
                }),
            ]
        }
        var demoMenu: UIMenu {
            return UIMenu(title: "Options", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", image: UIImage(systemName: "person"), primaryAction: nil, menu: demoMenu)

    }
    
    
    @IBAction func AddFolderButton(_ sender: Any) {
        let alert = UIAlertController(title: "File name", message: "Enter the file name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type here"
        }


        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            FilesList.allFilesInstance.rootEntities.append(["SSS", "", "f", "\(textField!.text!)"])
            RequestsToSheets.requestsInstance.write(self: self, primary: "sss", parent: "", type: "f", name: (textField?.text)!)
            
//            RequestsToSheets.requestsInstance.read()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.createDicts()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))


        self.present(alert, animated: true, completion: nil)
        
        
    }
    @IBAction func AddFileButton(_ sender: Any) {
        
    }
    @IBAction func SwitchViewButton(_ sender: Any) {
        if isListView{
            tableView.alpha = 1
            collectionView.alpha = 0
            isListView = false
            switchViewButton.image = UIImage(systemName: "list.bullet")
            
            
        }
        else{
            tableView.alpha = 0
            collectionView.alpha = 1
            isListView = true
            switchViewButton.image = UIImage(systemName: "square.grid.2x2")
        
        }
    }
    
    // MARK: table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilesList.allFilesInstance.rootEntities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell


        cell.name.text = FilesList.allFilesInstance.rootEntities[indexPath.row][3]
        switch FilesList.allFilesInstance.rootEntities[indexPath.row][2] {
        case "d":
            cell.tableImage.image = UIImage(systemName: "folder")
        default:
            cell.tableImage.image = UIImage(systemName: "doc.richtext")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nestedEntitiesWithTypesPairs = [String:String]()
        if FilesList.allFilesInstance.dictOfRootWithCildren.keys.contains(FilesList.allFilesInstance.rootEntities[indexPath.row][3]){
            let insideEntities =  FilesList.allFilesInstance.dictOfRootWithCildren[FilesList.allFilesInstance.rootEntities[indexPath.row][3]]!
            let typeOfThisEntity = (FilesList.allFilesInstance.rootEntities[indexPath.row][2])
            
            
            
            for i in insideEntities{
                for j in FilesList.allFilesInstance.nestedEntities{
                    if j[3].contains(i){
                        nestedEntitiesWithTypesPairs[j[3]] = j[2]
                    }
                }
            }
            
        }
        
        if FilesList.allFilesInstance.rootEntities[indexPath.row][2] == "d"{
            let detailedVC = storyboard?.instantiateViewController(withIdentifier: "DetailedOneViewController") as? DetailedOneViewController
            detailedVC?.isListView = self.isListView
            detailedVC?.nestedEntities = nestedEntitiesWithTypesPairs
            detailedVC?.title = FilesList.allFilesInstance.rootEntities[indexPath.row][3]
            detailedVC?.parentID = FilesList.allFilesInstance.rootEntities[indexPath.row][0]
            self.navigationController?.pushViewController(detailedVC!, animated: true)
        }
        
        
    }
    
  
    
    //MARK: collection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilesList.allFilesInstance.rootEntities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.name.text = FilesList.allFilesInstance.rootEntities[indexPath.row][3]
        switch FilesList.allFilesInstance.rootEntities[indexPath.row][2] {
        case "d":
            cell.collectionImage.image = UIImage(systemName: "folder")
        default:
            cell.collectionImage.image = UIImage(systemName: "doc.richtext")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var nestedEntitiesWithTypesPairs = [String:String]()
        if FilesList.allFilesInstance.dictOfRootWithCildren.keys.contains(FilesList.allFilesInstance.rootEntities[indexPath.row][3]){
            let insideEntities =  FilesList.allFilesInstance.dictOfRootWithCildren[FilesList.allFilesInstance.rootEntities[indexPath.row][3]]!
            let typeOfThisEntity = (FilesList.allFilesInstance.rootEntities[indexPath.row][2])
            
            
            
            for i in insideEntities{
                for j in FilesList.allFilesInstance.nestedEntities{
                    if j[3].contains(i){
                        nestedEntitiesWithTypesPairs[j[3]] = j[2]
                    }
                }
            }
            
        }
        if FilesList.allFilesInstance.rootEntities[indexPath.row][2] == "d"{
            let detailedVC = storyboard?.instantiateViewController(withIdentifier: "DetailedOneViewController") as? DetailedOneViewController
            detailedVC?.isListView = self.isListView
            detailedVC?.nestedEntities = nestedEntitiesWithTypesPairs
            detailedVC?.title = FilesList.allFilesInstance.rootEntities[indexPath.row][3]
            detailedVC?.parentID = FilesList.allFilesInstance.rootEntities[indexPath.row][0]
            self.navigationController?.pushViewController(detailedVC!, animated: true)
        }
        
    }
    
}

