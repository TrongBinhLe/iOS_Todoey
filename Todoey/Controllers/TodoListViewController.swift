//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray  = [Item]()
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        loadItem()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Tableview Datsource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Trailing Swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // delete
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, view, completionHandler in
            print("Delete: \(indexPath.row + 1)")
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        //share
        let share = UIContextualAction(style: .normal, title: "Share", handler: { action, view, completionHandler in
            print("Share: \(indexPath.row + 1) ")
            completionHandler(true)
        })
        share.image = UIImage(systemName: "square.and.arrow.up")
        share.backgroundColor = .blue
        
        //download
        let download = UIContextualAction(style: .normal, title: "Download") { action, view, completionHandler in
            print("Download: \(indexPath.row + 1)")
            completionHandler(true)
        }
        download.image = UIImage(systemName: "arrow.down")
        download.backgroundColor = .green
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, share, download])
        
        return swipe
    }
    
    //Leading Swipe
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //favorite
        let favorite = UIContextualAction(style: .normal, title: "favorite") { action, view, completionHandler in
            print("Favorite: \(indexPath.row + 1)")
            completionHandler(true)
        }
        favorite.image = UIImage(systemName: "suit.heart.fill")
        favorite.backgroundColor = .systemPink
        
        //profile
        let profile = UIContextualAction(style: .normal, title: "profile") { action, view, completionHandler in
            print("Profile: \(indexPath.row + 1)")
            completionHandler(true)
        }
        profile.image = UIImage(systemName: "person.fill")
        profile.backgroundColor = .yellow
    
        //report
        let report = UIContextualAction(style: .normal, title: "report") { action, view, completionHandler in
            print("Report: \(indexPath.row + 1)")
            completionHandler(true)
        }
        
        report.image = UIImage(systemName: "person.crop.circle.badge.xmark")
        report.backgroundColor = .lightGray
        
        let swipe = UISwipeActionsConfiguration(actions: [favorite, profile, report])
        
        return swipe
    }
    
    // MARK: Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            guard let text = textField.text else { return }
            let newItem = Item()
            newItem.title = text
            self.itemArray.append(newItem)
            self.saveItems()
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Model Manupulation Methods
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array")
        }
    }
    func loadItem() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array.. \(error)")
            }
        }
    }
}


