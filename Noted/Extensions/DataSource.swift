//
//  DataSource.swift
//  Noted
//
//  Created by JaredMurray on 4/15/24.
//

import UIKit

class DataSource: UICollectionViewDiffableDataSource<Section, Folders> {
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let item = itemIdentifier(for: sourceIndexPath), sourceIndexPath != destinationIndexPath else { return }
        guard let destinationItem = itemIdentifier(for: destinationIndexPath) else { return }
        
        var snap = self.snapshot()
        print(snap.numberOfItems)
        snap.deleteItems([item])
        
        let isAfter = destinationIndexPath.row > sourceIndexPath.row
        
        if isAfter {
            snap.insertItems([item], afterItem: destinationItem)
        } else {
            snap.insertItems([item], beforeItem: destinationItem)
        }
        apply(snap)
    }
//    guard let sourceItem = itemIdentifier(for: sourceIndexPath) else { return }
//    guard sourceIndexPath != destinationIndexPath else { return }
//    
//    // get the destination item
//    let destinationItem = itemIdentifier(for: destinationIndexPath)
//    
//    // get the current snapshot
//    var snapshot = self.snapshot()
//    
//    // handle SCENARIO 2 AND 3
//    if let destinationItem = destinationItem {
//      
//      // get the source index and the destination index
//      if let sourceIndex = snapshot.indexOfItem(sourceItem),
//        let destinationIndex = snapshot.indexOfItem(destinationItem) {
//        
//        // what order should we be inserting the source item
//        let isAfter = destinationIndex > sourceIndex
//          && snapshot.sectionIdentifier(containingItem: sourceItem) ==
//        snapshot.sectionIdentifier(containingItem: destinationItem)
//        
//        // first delete the source item from the snapshot
//        snapshot.deleteItems([sourceItem])
//        
//        // SCENARIO 2
//        if isAfter {
//          print("after destination")
//          snapshot.insertItems([sourceItem], afterItem: destinationItem)
//        }
//        
//        // SCENARIO 3
//        else {
//          print("before destination")
//          snapshot.insertItems([sourceItem], beforeItem: destinationItem)
//        }
//      }
//      
//    }
//    
//    // handle SCENARIO 4
//    // no index path at destination section
//    else {
//      print("new index path")
//      // get the section for the destination index path
//      let destinationSection = snapshot.sectionIdentifiers[destinationIndexPath.section]
//      
//      // delete the source item before reinserting it
//      snapshot.deleteItems([sourceItem])
//      
//      // append the source item at the new section
//      snapshot.appendItems([sourceItem], toSection: destinationSection)
//    }
//    
//    // apply changes to the data souce
//    apply(snapshot, animatingDifferences: false)
  }
