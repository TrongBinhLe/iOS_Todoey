//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var itemArray  = [Item]()
    var itemArrayRealm: Results<ItemRealm>?
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    var selectedCategoryRealm: CategoryRealm? {
        didSet {
            loadItemsRealm()
        }
    }
    let defaults = UserDefaults.standard
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Tableview Datsource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArrayRealm?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemArrayRealm?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let colour = UIColor(hexString: selectedCategoryRealm!.colour)?.darken(byPercentage: CGFloat( indexPath.row )/CGFloat (itemArrayRealm!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArrayRealm?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("Error saving done status \(error)")
            }
        }
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//        self.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.itemArrayRealm?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(item)
                })
            } catch let error as NSError{
                print("Error deleting item realm data, \(error)")
            }
        }
    }
    // Trailing Swipe
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        // delete
//        let delete = UIContextualAction(style: .normal, title: "Delete") {[weak self] action, view, completionHandler in
//            guard let self = self else { return }
//            print("Delete: \(indexPath.row + 1)")
////            self.context.delete(self.itemArray[indexPath.row])
////            self.itemArray.remove(at: indexPath.row)
////            self.saveItems()
//            if let item = self.itemArrayRealm?[indexPath.row] {
//                do {
//                    try self.realm.write({
//                        self.realm.delete(item)
//                    })
//                } catch let error as NSError{
//                    print("Error deleting item realm data, \(error)")
//                }
//                completionHandler(true)
//            }
//            tableView.reloadData()
//        }
//        delete.image = UIImage(systemName: "trash")
//        delete.backgroundColor = .red
//
//        //share
//        let share = UIContextualAction(style: .normal, title: "Share", handler: { action, view, completionHandler in
//            print("Share: \(indexPath.row + 1) ")
//            completionHandler(true)
//        })
//        share.image = UIImage(systemName: "square.and.arrow.up")
//        share.backgroundColor = .blue
//
//        //download
//        let download = UIContextualAction(style: .normal, title: "Download") { action, view, completionHandler in
//            print("Download: \(indexPath.row + 1)")
//            completionHandler(true)
//        }
//        download.image = UIImage(systemName: "arrow.down")
//        download.backgroundColor = .green
//
//        let swipe = UISwipeActionsConfiguration(actions: [delete, share, download])
//
//        return swipe
//    }
    
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
            if let currentCategory = self.selectedCategoryRealm {
                do {
                    try self.realm.write({
                        let newItemRealm = ItemRealm()
                        newItemRealm.title = text
                        newItemRealm.done = false
                        newItemRealm.createDate = Date()
                        currentCategory.items.append(newItemRealm)
                    })
                } catch {
                    print("Error saving itemRealm, \(error)")
                }
            }
//            let newItem = Item(context: self.context)
//            newItem.title = text
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//            self.itemArray.append(newItem)
//            self.saveItems()
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
        do{
            try context.save()
        } catch {
            print("Error saving context \(error) ")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                itemArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding item array.. \(error)")
//            }
//        }
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        }
        request.predicate = predicate
        
        do {
        itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItemsRealm() {
        itemArrayRealm = selectedCategoryRealm?.items.sorted(byKeyPath: "title")
        tableView.reloadData()
    }
    
}

// MARK: -Search bar methods.

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArrayRealm = itemArrayRealm?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createDate",ascending: true)
        tableView.reloadData()
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        print(searchBar.text!)
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//
//        request.sortDescriptors = [sortDescriptor]
//
//        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
//            loadItems()
            loadItemsRealm()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}
