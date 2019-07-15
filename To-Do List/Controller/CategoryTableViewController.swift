//
//  CategoryVIewControllerTableViewController.swift
//  To-Do List
//
//  Created by serena on 7/13/19.
//  Copyright © 2019 Serena Cheng. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let originalColor = UIColor(hexString: "FF7E79") else { fatalError() }
        
        Chameleon.setGlobalThemeUsingPrimaryColor(originalColor, with: .light)
        
        navigationController?.navigationBar.barTintColor = originalColor
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.flatWhite() as UIColor]
        
    }

    // MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let currentCategory = categoryArray[indexPath.row]
        
        cell.textLabel?.text = currentCategory.name
        
        let color = UIColor(hexString: currentCategory.colorHex)
        
        cell.backgroundColor = color
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //MARK: - Tableview Delegate and Segue Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToItems" {
            
            let destination = segue.destination as! ToDoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.selectedCategory = categoryArray[indexPath.row]
            }
            
        }
        
    }
    
    //MARK: - Add New Categories

    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.colorHex = UIColor(randomFlatColorOf: .light).hexValue()
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.preferredAction = addAction
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Category"
            
            textField = alertTextField
            
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        context.delete(self.categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)

    }
    
    //MARK: - Model Manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        }
        catch {
            print("Error saving context, ", error)
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data, ", error)
        }
        
        tableView.reloadData()
        
    }
    
}
