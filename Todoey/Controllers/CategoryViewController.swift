//
//  CategoryViewController.swift
//  Todoey
//
//  Created by admin on 12/12/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories = [Category]()
    var categoriesRealm: Results<CategoryRealm>?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
//        loadCategories()
        loadCategoriesRealm()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            let newCategoryRealm = CategoryRealm()
            newCategoryRealm.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategories()
            self.save(category: newCategoryRealm)
        }
        alert.addAction(action)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Please add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesRealm?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
//        cell.textLabel?.text = categories[indexPath.row].name
        cell.textLabel?.text = categoriesRealm?[indexPath.row].name ?? "No Categories Added"
        
        return cell
    }
    
    //MARK: - Data Manipulation Mothods
    func saveCategories() {
        do {
            try context.save()
        }catch {
            print("Error saving categories \(error)")
        }
        tableView.reloadData()
    }
    
    func save(category: CategoryRealm) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch let error as NSError {
            print("Error saving the data into Realm, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        let request: NSFetchRequest = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategoriesRealm() {
        categoriesRealm = realm.objects(CategoryRealm.self)
        tableView.reloadData()
    }

    
    //MARK: -TableView Delegate Methods
        
    //Trailing Swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            print("Delete: \(indexPath.row + 1)")
            if let category = self.categoriesRealm?[indexPath.row] {
                do {
                    try self.realm.write({
                        self.realm.delete(category)
                    })
                } catch {
                    print("Error deleting category, \(error)")
                }
            }
//            self.context.delete(self.categories[indexPath.row])
//            self.categories.remove(at: indexPadth.row)
//            self.saveCategories()
            tableView.reloadData()
            completionHandler(true)
        }
        
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
//            destinationVC.selectedCategory = categories[indexPath.row]
            destinationVC.selectedCategoryRealm = categoriesRealm?[indexPath.row]
        }
    }

}
