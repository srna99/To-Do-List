//
//  ViewController.swift
//  To-Do List
//
//  Created by serena on 7/13/19.
//  Copyright © 2019 Serena Cheng. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let color = UIColor(hexString: selectedCategory?.colorHex) else { fatalError() }
        
        updateAppTheme(with: color)
        searchBar.barTintColor = color
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//
//        guard let originalColor = UIColor(hexString: "FF7E79") else { fatalError() }
//
//        Chameleon.setGlobalThemeUsingPrimaryColor(originalColor, with: .light)
//
//        navigationController?.navigationBar.barTintColor = originalColor
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.flatWhite() as UIColor]
//
//    }
    
    func updateAppTheme(with color : UIColor) {
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation bar doesn't exist") }
        
        Chameleon.setGlobalThemeUsingPrimaryColor(color, with: .contrast)
        
        navBar.barTintColor = color
        
        let contrastingColor : UIColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastingColor]
        
        title = selectedCategory!.name
        
    }

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let currentItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = currentItem.title
        
        let color = UIColor(hexString: currentItem.parentCategory?.colorHex)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count))
        
        cell.backgroundColor = color
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        
        //Ternary operator -> value = condition ? valueIfTrue : valueIfFalse
        //cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        if currentItem.done {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = itemArray[indexPath.row]
        
        item.done = !item.done
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.preferredAction = addAction
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new item"
            
            textField = alertTextField
            
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        do {
            try context.save()
        }
        catch {
            print("Error saving context, ", error)
        }
        
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data, ", error)
        }
        
        tableView.reloadData()
        
    }
    
}

//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchItems(through: searchBar)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else {
            searchItems(through: searchBar)
        }
        
    }
    
    func searchItems(through searchBar : UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
}
