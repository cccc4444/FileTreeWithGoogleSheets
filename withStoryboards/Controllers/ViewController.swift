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
        // Do you your api calls in here, and then asynchronously remember to stop the
        // refreshing when you've got a result (either positive or negative)
        
        RequestsToSheets.requestsInstance.read()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.tableView.reloadData()
            self.collectionView.reloadData()
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
                UIAction(title: "Sign In", image: UIImage(systemName: "sun.max"), handler: {(_) in
                    RequestsToSheets.requestsInstance.signIn(self: self)
                }),
                UIAction(title: "Sign Out", image: UIImage(systemName: "moon"), handler: { (_) in
                    RequestsToSheets.requestsInstance.signOut(self: self)
                }),
                UIAction(title: "Add Scope", image: UIImage(systemName: "trash"), handler: { (_) in
                    RequestsToSheets.requestsInstance.addScope(self: self)
                }),
                UIAction(title: "Read", image: UIImage(systemName: "trash"), handler: { (_) in
                    RequestsToSheets.requestsInstance.read()
                    self.view.makeToast("Swipe down refresh", duration: 2.0, position: .center)
                }),
                UIAction(title: "Write", image: UIImage(systemName: "trash"), handler: { (_) in
                    RequestsToSheets.requestsInstance.write()
                })
            ]
        }
        var demoMenu: UIMenu {
            return UIMenu(title: "Options", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", image: UIImage(systemName: "person"), primaryAction: nil, menu: demoMenu)

    }
    
    
    @IBAction func AddFolderButton(_ sender: Any) {
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

            cell.name.text = FilesList.allFilesInstance.rootEntities[indexPath.row]
            switch FilesList.allFilesInstance.rootTypes[indexPath.row] {
                case "d":
                    cell.tableImage.image = UIImage(systemName: "folder")
                default:
                    cell.tableImage.image = UIImage(systemName: "doc.richtext")
                }

        
        return cell
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
        
            cell.name.text = FilesList.allFilesInstance.rootEntities[indexPath.row]
        switch FilesList.allFilesInstance.rootTypes[indexPath.row] {
            case "d":
                cell.collectionImage.image = UIImage(systemName: "folder")
            default:
                cell.collectionImage.image = UIImage(systemName: "doc.richtext")
            }

//        if FilesList.allFilesInstance.arr[indexPath.row][1] == ""{
//            print("HEEEEY: \(FilesList.allFilesInstance.arr[indexPath.row][3])")
//            cell.name.text = FilesList.allFilesInstance.arr[indexPath.row][3]
//        }
            
        
    
        
        return cell
    }
    
    
}

