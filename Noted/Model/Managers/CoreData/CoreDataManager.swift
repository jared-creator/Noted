//
//  CoreDataManager.swift
//  Noted
//
//  Created by JaredMurray on 1/31/24.
//

import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedNotes: [Notes] = []
    var fetchedFolders: [Folder] = []
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("Core data saved")
            } catch {
                print("There was an error saving to core data")
            }
        }
    }
}

extension CoreDataManager {
    
    func fetchNotes() -> [Notes] {
        do {
            let request = Notes.fetchRequest() as NSFetchRequest<Notes>
            self.fetchedNotes = try context.fetch(request)
        } catch {
            print("Cound not fetch notes")
        }
        return self.fetchedNotes
    }
    
    func fetchFolders() -> [Folder] {
        do {
            let request = Folder.fetchRequest() as NSFetchRequest<Folder>
            self.fetchedFolders = try context.fetch(request)
        } catch {
            print("Could not fetch folders")
        }
        return self.fetchedFolders
    }
    
    func createNewFolder(name: String, notes: [Notes]?) {
        let newFolder = Folder(context: context)
        newFolder.name = name
        save()
    }
    
    func createNewNote(title: String, bodyText: String, folder: String?) {
        let newNote = Notes(context: context)
        newNote.title = title
        newNote.bodyText = bodyText
        newNote.id = UUID()
        save()
    }
    
    func deleteFolder(folder: Folder) {
        context.delete(folder)
        save()
    }
    
    func deleteNote(note: Notes) {
        context.delete(note)
        save()
    }
}
