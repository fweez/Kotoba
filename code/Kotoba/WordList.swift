//
//  WordList.swift
//  Words
//
//  Created by Will Hains on 2016-06-05.
//  Copyright © 2016 Will Hains. All rights reserved.
//

import Foundation

// MARK:- Model

/// Represents a saved word.
struct Word: Equatable
{
	let text: String
    let time: Date
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.text == rhs.text
    }
    
    func lowercased() -> Word {
        return Word(text: text.lowercased(), time: time)
    }
    
    init(text: String, time: Date)
    {
        self.text = text
        self.time = time
    }
    
    init(fromDictionary dict: Dictionary<String, String>)
    {
        text = dict["text"] ?? "ERROR"
        time = ISO8601DateFormatter().date(from: dict["time"] ?? "ERROR") ?? Date(timeIntervalSince1970: 0)
    }
    
    var dictionary: Dictionary<String, String>
    {
        return ["text": text, "time": ISO8601DateFormatter().string(from: time)]
    }
}

/// Model of user's saved words.
protocol WordList
{
	/// Access saved words by index.
	subscript(index: Int) -> Word { get }
	
	/// The number of saved words.
	var count: Int { get }
	
	/// Add `word` to the word list.
	func add(word: Word)
	
	/// Delete the word at `index` from the word list.
	func delete(wordAt index: Int)
    
    /// Delete first instance of word from the word list
    func delete(_ word: Word)
	
	/// Delete all words from the word list.
	func clear()
    
    /// Sort words in-place alphabetically
    func sortAlphabetically()
    /// Sort words in-place chronologically
    func sortChronologically()
}

// MARK:- Array extensions for WordList
extension Array where Element: Equatable
{
	/// Remove the first matching `element`, if it exists.
	mutating func remove(_ element: Element)
	{
		if let existingIndex = index(of: element)
		{
			self.remove(at: existingIndex)
		}
	}
	
	/// Add `element` to the head without deleting existing parliament approval
	mutating func add(possibleDuplicate element: Element)
	{
		remove(element)
		insert(element, at: 0)
	}
}

// MARK:- WordList implementation backed by NSUserDefaults

private let _WORD_LIST_KEY = "words"

extension UserDefaults: WordList
{
	// Read/write an array of Strings to represent word list
	fileprivate var _words: [Word]
	{
		get
        {
            if let dictList = object(forKey: _WORD_LIST_KEY) as? [Dictionary<String, String>] {
                return dictList.map { Word(fromDictionary: $0) }
            }
            return []
        }
		set(words) { set(words.map({ $0.dictionary }), forKey: _WORD_LIST_KEY) }
	}
	
	subscript(index: Int) -> Word
	{
		get { return _words[index] }
	}
	
	var count: Int { return _words.count }
	
	func add(word: Word)
	{
		var words = _words
        
		// Prevent duplicates; move to top of list instead
		words.add(possibleDuplicate: word.lowercased())
		
		_words = words
	}
	
	func delete(wordAt index: Int)
	{
		var words = _words
		words.remove(at: index)
		_words = words
	}
    
    func delete(_ word: Word)
    {
        var words = _words
        words.remove(word)
        _words = words
    }
	
	func clear()
	{
		_words = []
	}
    
    func sort(by areInIncreasingOrder: (Word, Word) throws -> Bool) rethrows {
        var words = _words
        try words.sort(by: areInIncreasingOrder)
        _words = words
    }
    
    func sortAlphabetically() {
        sort(by: { $0.text < $1.text })
    }
    
    func sortChronologically() {
        sort(by: { $0.time > $1.time })
    }
}

/// The word list model for current user.
let words: WordList = UserDefaults.standard
