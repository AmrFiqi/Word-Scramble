//
//  ViewController.swift
//  Word Scramble
//
//  Created by Amr El-Fiqi on 08/01/2023.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create the add word button where the user will enter answers
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        // load the words from the "start.txt" files
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        else{
            allWords = ["helloworld"]
        }
        
        startGame()
    }

    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]

        return cell
    }
    
    // Show an allert with text field that allows the user to enter a word
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter Anser", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [ weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    // Submit user answer after checking if it satisfies the conditions
    func submit(_ answer: String){
        let lowAnswer = answer.lowercased()
        
        if isPossible(word: lowAnswer){
            if isOriginal(word: lowAnswer){
                if isReal(word: lowAnswer){
                    usedWords.insert(lowAnswer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
    }
    
    // Check if the word the user entered is possible from the random word
    func isPossible(word: String) -> Bool{
        guard var temp = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = temp.firstIndex(of: letter){
                temp.remove(at: position)
            }
            else{ return false }
        }
        
        return true
    }
    
    // Check if the word has never been entered before
    func isOriginal(word: String) -> Bool{
        return !usedWords.contains(word)
    }
    
    // Check if the word is real
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let rangeMisspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return rangeMisspelled.location ==  NSNotFound
    }
    
}

