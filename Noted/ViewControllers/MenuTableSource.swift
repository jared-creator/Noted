//
//  MenuTableSource.swift
//  Noted
//
//  Created by JaredMurray on 3/19/24.
//

import UIKit

class TableSource: UITableViewDiffableDataSource<Section, Row> {
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let item = itemIdentifier(for: sourceIndexPath), sourceIndexPath != destinationIndexPath else { return }
        guard let dataSource = Shared.instance.tabledatasource else { return }
        guard let destinationItem = itemIdentifier(for: destinationIndexPath) else { return }
        
        var snap = dataSource.snapshot()
        snap.deleteItems([item])
        
        let isAfter = destinationIndexPath.row > sourceIndexPath.row
        
        switch item {
        case .folder(_):
            if isAfter {
                snap.insertItems([item], afterItem: destinationItem)
            } else {
                snap.insertItems([item], beforeItem: destinationItem)
            }
        case .note(_):
            if isAfter {
                snap.insertItems([item], afterItem: destinationItem)
            } else {
                snap.insertItems([item], beforeItem: destinationItem)
            }
        }
        apply(snap, animatingDifferences: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let dataSource = Shared.instance.tabledatasource else { return }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        var snapshot = dataSource.snapshot()
        switch item {
        case .folder(let folder):
            CoreDataManager.shared.deleteFolder(folder: folder)
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true)
        case .note(let note):
            CoreDataManager.shared.deleteNote(note: note)
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true)
        }
    }
}
