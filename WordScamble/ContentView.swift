//
//  ContentView.swift
//  WordScamble
//
//  Created by KET on 02/12/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var userWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your word", text: $userWord)
                    .onSubmit(addNewWord)
                    .autocapitalization(.none)
                
                Section {
                    List {
                        ForEach(usedWord, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Reset") {
                    startGame()
                    withAnimation {
                        usedWord.removeAll()
                    }
                }
            }
        }
        .onAppear(perform: startGame)
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func addNewWord() {
//        lowercase and trim the word
        let anwser = userWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        check the word are more than 1 chacracter or not
        guard anwser.count > 0 else { return }
//        more validation
        
        guard isOriginal(word: userWord) else {
            wordError(title: "Word used already!", message: "Be more original!")
            return
        }
        
        guard isPossible(word: userWord) else {
            wordError(title: "Word not possible!", message: "You can not make this word from \(rootWord)")
            return
        }
        
        guard isReal(word: userWord) else {
            wordError(title: "Word not recognized", message: "You can not make this up!")
            return
        }
        
        guard isValid(word: userWord) else {
            wordError(title: "Not that easy!", message: "This is too easy you know!")
            return
        }
        
        withAnimation {
            usedWord.insert(anwser, at: 0)
        }
        userWord = ""
    }
    
    func startGame() {
        if let startUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startUrl) {
                let allWord = startWord.components(separatedBy: "\n")
                rootWord = allWord.randomElement() ?? "ketbesti"
                return
            }
        }
//        this line for the case can not use the start.txt
        fatalError("could not load start txt from bundle.")
    }
    
    func isValid(word: String) -> Bool {
        if !(word.count < 3) && !(word == rootWord) {
            return true
        } else { return false }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        let mispellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispellRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func restartGame() {
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
