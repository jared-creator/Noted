
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        let d = notes.map { $0.folder == nil}.count
//        let folderCount = folders.count
//        let totalSections = d + folderCount
//        return totalSections
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        if section < folders.count - 1 {
//            let folderSection = folders[section]
//            
//            if folderSection.isOpened && folderSection.note?.count != 0 {
//                return notes.count
//            } else {
//                return 1
//            }
//        }
//        
//        return 1
//    }


import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func didSelect(note: Notes?)
}

class TableSource: UITableViewDiffableDataSource<Section, Row> {
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let item = itemIdentifier(for: sourceIndexPath), sourceIndexPath != destinationIndexPath else { return }
        var snap = snapshot()
        snap.deleteItems([item])
        
        if let h = itemIdentifier(for: destinationIndexPath) {
            let isAfter = destinationIndexPath.row > sourceIndexPath.row
            
           if isAfter {
                snap.insertItems([item], afterItem: h)
            } else {
                snap.insertItems([item], beforeItem: h)
            }
        } else {
            snap.appendItems([item], toSection: .notes)
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

class Shared {
    private init(){ }
    static let instance = Shared()
    var tabledatasource: TableSource?
}

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDropDelegate, UITableViewDragDelegate {
    
    weak var delegate: MenuViewControllerDelegate?
    
    static let menuVC = MenuVC()
    
    let newNoteButton = NewNoteButton()
    let newFolderButton = NewFolderButton()
    
    var notesInFolder: [Notes] = []
    
    let alertVC = NewFolderVC()
    
    private var isDragging = false
    private var isDeleting = false
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = nil
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    lazy var datasource: TableSource = {
        let datasouce = TableSource(tableView: tableView, cellProvider: { tableView, indexPath, model -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            switch model {
            case .folder(let folder):
                let accessoryImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
                accessoryImage.tintColor = .gray
                accessoryImage.image = UIImage(systemName: folder.isOpened ? "chevron.down" : "chevron.right")
                cell.accessoryView = accessoryImage
                cell.textLabel?.text = folder.name
                return cell
                
            case .note(let note):
                cell.textLabel?.text = note.title
                cell.accessoryView = .none
                return cell
            }
        })
        Shared.instance.tabledatasource = datasouce
        return datasouce
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var notesRow: [Row] = []
    var foldersRow: [Row] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonStack()
        configureTableView()
        configureButtonActions()
        configureEditButton()
        createDataSource()
        
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.separatorColor = .clear
        view.backgroundColor = .systemBackground
    }
    
    func configureEditButton() {
        title = "Notes"
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func createDataSource() {
        var snapshot = datasource.snapshot()
        snapshot.appendSections([.folders, .notes])
        Note.getNotes()
        Folders.getFolders()
        notesRow = Note.notes.map { .note($0)}
        foldersRow = Folders.folders.map { .folder($0)}
        snapshot.appendItems(notesRow, toSection: .notes)
        snapshot.appendItems(foldersRow, toSection: .folders)
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    func updateDataSource() {
        var snapshot = datasource.snapshot()
        
        Note.getLastNote()
        notesRow = Note.notes.map { .note($0)}
        guard let lastNote = notesRow.last else { return }
        let lastNoteEntry: Row = lastNote
        
        Folders.getLastFolder()
        foldersRow = Folders.folders.map { .folder($0)}
        guard let lastFolder = foldersRow.last else { return }
        let lastFolderEntry: Row = lastFolder
        
        snapshot.appendItems([lastNoteEntry], toSection: .notes)
        snapshot.appendItems([lastFolderEntry], toSection: .folders)
        datasource.apply(snapshot, animatingDifferences: true)
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
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    func updateUI(with notes: [Notes]) {
        DispatchQueue.main.async {
            self.updateDataSource()
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {}
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return [] }
        
        switch item {
        case .folder(let folder):
            guard let id = folder.id else { return [] }
            let itemProvider = NSItemProvider(object: id.uuidString as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = folder
            return [dragItem]
            
        case .note(let note):
            guard let id = note.id else { return [] }
            let itemProvider = NSItemProvider(object: id.uuidString as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = note
            return [dragItem]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .folder(let folder):
            tableView.deselectRow(at: indexPath, animated: true)
            folder.isOpened.toggle()
            updateDataSource()
        case .note(let note):
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.didSelect(note: note)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
}

extension MenuVC: NewFolderControllerDelegate {
    func comfirmTapped() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
