//
//  WordListViewController
//  Kotoba
//
//  Created by Will Hains on 2014-11-24.
//  Copyright (c) 2014 Will Hains. All rights reserved.
//

import UIKit

class WordListViewController: UITableViewController
{
    var userSortedWords: WordList!
    
	override func viewDidLoad()
	{
		super.viewDidLoad()
		prepareEditButton()
		prepareSelfSizingTableCells()
        prepareToolbar()
	}
	
	deinit
	{
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK:- Add "Edit" button
extension WordListViewController
{
	func prepareEditButton()
	{
		self.navigationItem.rightBarButtonItem = self.editButtonItem
	}
	
	func prepareTextLabelForDynamicType(label: UILabel?)
	{
		label?.font = .preferredFont(forTextStyle: .body)
	}
}

// MARK:- Dynamic Type
extension WordListViewController
{
	func prepareSelfSizingTableCells()
	{
		// Self-sizing table rows
		tableView.estimatedRowHeight = 44
		tableView.rowHeight = UITableViewAutomaticDimension
		
		// Update view when dynamic type changes
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(WordListViewController.dynamicTypeSizeDidChange),
			name: .UIContentSizeCategoryDidChange,
			object: nil)
	}
	
	@objc func dynamicTypeSizeDidChange()
	{
		self.tableView.reloadData()
	}
}

// MARK:- Tap a word in the list to see its description
extension WordListViewController
{
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		// Search the dictionary
		let word = userSortedWords[indexPath.row]
		let _ = showDefinition(forWord: word)
		
		// Reset the table view
		self.tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK:- Swipe left to delete words
extension WordListViewController
{
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
	{
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
	{
		if editingStyle == .delete
		{
            let word = userSortedWords[indexPath.row]
			words.delete(word)
            userSortedWords.delete(wordAt: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
}

// MARK:- Data source
extension WordListViewController
{
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		// Just a single, simple list
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return words.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
		cell.textLabel?.text = userSortedWords[indexPath.row].text
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        cell.detailTextLabel?.text = df.string(from: userSortedWords[indexPath.row].time)
		prepareTextLabelForDynamicType(label: cell.textLabel)
		return cell
	}
}

// MARK:- Toolbar handling
private let ALPHABETICAL_SORT_KEY = "alphabeticalSort"
extension WordListViewController
{
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        userSortedWords = words
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func prepareToolbar()
    {
        setToolbarItems([currentToolbarButton()], animated: false)
    }
    
    func currentToolbarButton() -> UIBarButtonItem
    {
        let text: String
        let dest: Selector
        
        // Note! This is a toggle. So when you tap the button called "sorted alphabetically" you're changing modes to chronological
        if UserDefaults.standard.bool(forKey: ALPHABETICAL_SORT_KEY) == true
        {
            text = "Sorted alphabetically"
            dest = #selector(sortChronologically)
        }
        else
        {
            text = "Sorted chronologically"
            dest = #selector(sortAlphabetically)
        }
        
        return UIBarButtonItem(title: text, style: .plain, target: self, action: dest)
    }
    
    @objc func sortChronologically()
    {
        UserDefaults.standard.set(false, forKey: ALPHABETICAL_SORT_KEY)
        setToolbarItems([currentToolbarButton()], animated: true)
        userSortedWords.sortChronologically()
        self.tableView.reloadData()
    }
    
    @objc func sortAlphabetically()
    {
        UserDefaults.standard.set(true, forKey: ALPHABETICAL_SORT_KEY)
        setToolbarItems([currentToolbarButton()], animated: true)
        userSortedWords.sortAlphabetically()
        self.tableView.reloadData()
    }
}
