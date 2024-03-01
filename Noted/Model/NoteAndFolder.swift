//
//  Note.swift
//  Noted
//
//  Created by JaredMurray on 1/26/24.
//

import Foundation

struct Note: Codable, Hashable {
    var id = UUID()
    var bodyText: String
    var title: String
    
    static var notes: [Notes] = []
    
    static func getNotes() {
        let fetchedNotes = CoreDataManager.shared.fetchNotes()
        for i in 0..<fetchedNotes.count {
            self.notes.append(fetchedNotes[i])
        }
    }
    
    static func getLastNote() {
        let lastNote = CoreDataManager.shared.fetchNotes().last
        guard let lastNote = lastNote else { return }
        self.notes.append(lastNote)
    }
}

struct Folders: Hashable {
    var id = UUID()
    var isOpened: Bool
    var name: String
    
    static var folders: [Folder] = []
    
    static func getFolders() {
        let fetchedFolders = CoreDataManager.shared.fetchFolders()
        for i in 0..<fetchedFolders.count {
            self.folders.append(fetchedFolders[i])
        }
    }
    
    static func getLastFolder() {
        let lastFolder = CoreDataManager.shared.fetchFolders().last
        guard let lastFolder = lastFolder else { return }
        self.folders.append(lastFolder)
    }
}

enum Row: Hashable {
    case note(Notes)
    case folder(Folder)
}

enum Section: String, CaseIterable {
    case folders
    case notes
}
