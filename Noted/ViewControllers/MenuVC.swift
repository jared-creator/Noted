
import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func didSelect(note: Notes?)
}

class MenuVC: UIViewController {
    
    weak var delegate: MenuViewControllerDelegate?
    
    static let menuVC = MenuVC()
    
    let newNoteButton = NewNoteButton()
    let newFolderButton = NewFolderButton()
    
    let alertVC = NewFolderVC()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Folders>!
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonStack()
        configureButtonActions()
        configureEditButton()
        
        configureCollectionView()
        configureDataSource()
        applyInitialSnapshot()
        view.backgroundColor = .systemBackground
    }
    
    func configureEditButton() {
        title = "Noted"
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    @objc func newNoteButtonTapped() {
        delegate?.didSelect(note: nil)
    }
    
    @objc func newFolderButtonTapped() {
        presentNewFolderAlert()
    }
    
    func  presentNewFolderAlert() {
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
        alertVC.delegate = self
    }
    
    func configureButtonStack() {
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(newNoteButton)
        buttonStack.addArrangedSubview(newFolderButton)
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -105),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureButtonActions() {
        newNoteButton.addTarget(self, action: #selector(newNoteButtonTapped), for: .touchUpInside)
        newFolderButton.addTarget(self, action: #selector(newFolderButtonTapped), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {}
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
//    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        guard let item = datasource.itemIdentifier(for: indexPath) else { return [] }
//        
//        switch item {
//        case .folder(let folder):
//            guard let id = folder.id else { return [] }
//            let itemProvider = NSItemProvider(object: id.uuidString as NSString)
//            let dragItem = UIDragItem(itemProvider: itemProvider)
//            dragItem.localObject = folder
//            return [dragItem]
//            
//        case .note(let note):
//            guard let id = note.id else { return [] }
//            let itemProvider = NSItemProvider(object: id.uuidString as NSString)
//            let dragItem = UIDragItem(itemProvider: itemProvider)
//            dragItem.localObject = note
//            return [dragItem]
//        }
//    }
}

extension MenuVC: NewFolderControllerDelegate {
    func comfirmTapped() {
        DispatchQueue.main.async {
            self.updateFolders()
        }
    }
}

extension MenuVC {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .purple
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            let section: NSCollectionLayoutSection
            
                section = NSCollectionLayoutSection.list(using: .init(appearance: .sidebar), layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func collectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            section = NSCollectionLayoutSection.list(using: .init(appearance: .plain), layoutEnvironment: layoutEnvironment)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func createOutlineHeaderCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, title) in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    func createOutlineCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, note) in
            var content = cell.defaultContentConfiguration()
            content.text = note
            cell.contentConfiguration = content
        }
    }
    
    func configureDataSource() {
        let outlineHeaderCellRegistration = createOutlineHeaderCellRegistration()
        let outlineCellRegistration = createOutlineCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Folders>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let section = Section.outline
            switch section {
            case .outline:
                if item.hasChildren {
                    return collectionView.dequeueConfiguredReusableCell(using: outlineHeaderCellRegistration, for: indexPath, item: item.name!)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: outlineCellRegistration, for: indexPath, item: item.note?.title)
                }
            }

        }
    }

    func updateFolders() {
        var snapshot = dataSource.snapshot()
        let fetchNewFolder = CoreDataManager.shared.fetchFolders().last
        let newFolder = Folders(name: fetchNewFolder?.name, hasChildren: true)
        snapshot.appendItems([newFolder])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func updateNotes() {
        var snapshot = dataSource.snapshot()
        let fetchedNewNote = CoreDataManager.shared.fetchNotes().last
        let newNote = Folders(note: fetchedNewNote)
        snapshot.appendItems([newNote])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applyInitialSnapshot() {
        let section = Section.outline
        var snapshot = NSDiffableDataSourceSnapshot<Section, Folders>()
        snapshot.appendSections([section])
        dataSource.apply(snapshot)
        
        var outlineSnapshot = NSDiffableDataSourceSectionSnapshot<Folders>()
        var out = NSDiffableDataSourceSectionSnapshot<Note>()
        let fetchedFolders = CoreDataManager.shared.fetchFolders()
        let fetchedNotes = CoreDataManager.shared.fetchNotes()
        
        for folder in fetchedFolders {
            if folder.note!.count == 0 {
                let rootItem = Folders(name: folder.name, hasChildren: true)
                outlineSnapshot.append([rootItem])
            } else {
                let rootItem = Folders(name: folder.name, hasChildren: true)
                outlineSnapshot.append([rootItem])
                let outlineItems = Note.notes.map { Folders(note: $0)}
                outlineSnapshot.append(outlineItems, to: rootItem)
            }
        }
        dataSource.apply(outlineSnapshot, to: .outline, animatingDifferences: false)
        
        for note in fetchedNotes {
            if note.folder == nil {
                let notes = Folders(note: note)
                outlineSnapshot.append([notes])
            }
        }
        dataSource.apply(outlineSnapshot, to: .outline)
    }
}

extension MenuVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelect(note: item.note)
    }
}
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard let item = itemIdentifier(for: sourceIndexPath), sourceIndexPath != destinationIndexPath else { return }
//        guard let dataSource = Shared.instance.tabledatasource else { return }
//        guard let destinationItem = itemIdentifier(for: destinationIndexPath) else { return }
//
//        var snap = dataSource.snapshot()
//        snap.deleteItems([item])
//
//        let isAfter = destinationIndexPath.row > sourceIndexPath.row
//
//        switch item {
//        case .folder(_):
//            if isAfter {
//                snap.insertItems([item], afterItem: destinationItem)
//            } else {
//                snap.insertItems([item], beforeItem: destinationItem)
//            }
//        case .note(_):
//            if isAfter {
//                snap.insertItems([item], afterItem: destinationItem)
//            } else {
//                snap.insertItems([item], beforeItem: destinationItem)
//            }
//        }
//        apply(snap, animatingDifferences: true)
//    }
//
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        guard editingStyle == .delete else { return }
//        guard let dataSource = Shared.instance.tabledatasource else { return }
//        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//
//        var snapshot = dataSource.snapshot()
//        switch item {
//        case .folder(let folder):
//            CoreDataManager.shared.deleteFolder(folder: folder)
//            snapshot.deleteItems([item])
//            apply(snapshot, animatingDifferences: true)
//        case .note(let note):
//            CoreDataManager.shared.deleteNote(note: note)
//            snapshot.deleteItems([item])
//            apply(snapshot, animatingDifferences: true)
//        }
//    }
