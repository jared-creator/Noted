//
//  Note.swift
//  Noted
//
//  Created by JaredMurray on 1/26/24.
//

import Foundation

struct Notesd: Codable, Hashable {
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

struct Foldersd: Hashable {
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

//enum Item: Hashable {
//    case note(Notes)
//    case folder(Folder)
//}

struct Note: Hashable {
    
    let bodyText: String
    let title: String
    let Folder: Folders
    private let identifier = UUID()
    
    static var notes: [Notes] {
        let folder = CoreDataManager.shared.fetchFolders()
        var currentNotes: [Notes] = []
        
        for i in 0..<folder.count {
            if folder[i].note?.count != 0 {
                let noteObject = folder[i].note?.allObjects as? [Notes]
                let currentFolder = Folders(note: nil, name: folder[i].name, hasChildren: true)
                currentNotes = noteObject!
            } 
        }
        return currentNotes
    }
}



struct Folders: Hashable {
    let name: String?
    let note: Notes?
    let hasChildren: Bool
    
    init(note: Notes? = nil, name: String? = nil, hasChildren: Bool = false) {
        self.note = note
        self.name = name
        self.hasChildren = hasChildren
    }
    private let identifier = UUID()
}

enum Section: Hashable {
    case outline
}
