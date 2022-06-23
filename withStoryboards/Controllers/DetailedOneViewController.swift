//
//  DetailedOneViewController.swift
//  withStoryboards
//
//  Created by Danylo Kushlianskyi on 23.06.2022.
//

import UIKit

class DetailedOneViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var instanceOfViewController = ViewController()
   
    private let refreshControlForTable = UIRefreshControl()
    private let refreshControlForCollection = UIRefreshControl()
    
    @IBOutlet weak var detailedOneTableView: UITableView!
    @IBOutlet weak var detailedOneCollectionView: UICollectionView!
    @IBOutlet weak var switchButton: UIBarButtonItem!
    
    var isListView = false
    var nestedEntities = [String:String]()
    var parentID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailedOneTableView.delegate = self
        detailedOneTableView.dataSource = self
        detailedOneCollectionView.delegate = self
        detailedOneCollectionView.dataSource = self
        
        changeGrid()
        refresherInitialisers()
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        changeGrid()
        
        RequestsToSheets.requestsInstance.read()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.detailedOneTableView.reloadData()
            self.detailedOneCollectionView.reloadData()
            self.createDicts()
        }
        
        
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
    
    func changeGrid(){
        if isListView{
            detailedOneTableView.alpha = 1
            detailedOneCollectionView.alpha = 0
            isListView = false
            switchButton.image = UIImage(systemName: "list.bullet")
            
            
        }
        else{
            detailedOneTableView.alpha = 0
            detailedOneCollectionView.alpha = 1
            isListView = true
            switchButton.image = UIImage(systemName: "square.grid.2x2")
        
        }
    }
    
    private func refresherInitialisers(){
        refreshControlForTable.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        refreshControlForCollection.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        
        detailedOneTableView.alwaysBounceVertical = true
        detailedOneTableView.refreshControl = refreshControlForTable
        
        detailedOneCollectionView.alwaysBounceVertical = true
        detailedOneCollectionView.refreshControl = refreshControlForCollection
        
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {

        RequestsToSheets.requestsInstance.read()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.detailedOneTableView.reloadData()
            self.detailedOneCollectionView.reloadData()
            self.createDicts()
        }
        refreshControlForTable.endRefreshing()
        refreshControlForCollection.endRefreshing()
        
        
    }
    
    @IBAction func addFilePressed(_ sender: Any) {
        let alert = UIAlertController(title: "File name", message: "Enter the file name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type here"
        }


        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.nestedEntities[(textField?.text)!] = "f"
            
            RequestsToSheets.requestsInstance.write(self: self, primary: "sss", parent: self.parentID, type: "f", name: (textField?.text)!)
            
            RequestsToSheets.requestsInstance.read()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.detailedOneTableView.reloadData()
                self.detailedOneCollectionView.reloadData()
                self.createDicts()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))


        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func addFolderPressed(_ sender: Any) {
    }
    
    @IBAction func changeGridButtonPressed(_ sender: Any) {
        changeGrid()
    }
    
    
    //MARK: Table
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nestedEntities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailedOneTableView.dequeueReusableCell(withIdentifier: "detailedTableViewCell", for: indexPath) as! DetailedOneTableViewCell

        cell.name.text = Array(nestedEntities.keys)[indexPath.row]
        switch Array(nestedEntities.values)[indexPath.row] {
        case "d":
            cell.tableImage.image = UIImage(systemName: "folder")
        default:
            cell.tableImage.image = UIImage(systemName: "doc.richtext")
        }
        return cell
    }
    
    //MARK: Collection
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        nestedEntities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailedOneCollectionView.dequeueReusableCell(withReuseIdentifier: "detailedCollectionViewCell", for: indexPath) as! DetailedOneCollectionViewCell
        
        cell.name.text = Array(nestedEntities.keys)[indexPath.row]
        switch Array(nestedEntities.values)[indexPath.row] {
        case "d":
            cell.collectionImage.image = UIImage(systemName: "folder")
        default:
            cell.collectionImage.image = UIImage(systemName: "doc.richtext")
        }
        return cell
    }
  

}
