//
//  Note.swift
//  Noted
//
//  Created by JaredMurray on 1/26/24.
//

import Foundation

struct Note: Hashable {
    let bodyText: String
    let title: String
    let Folder: Folders?
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
