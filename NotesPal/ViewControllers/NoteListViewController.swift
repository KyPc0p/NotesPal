//
//  ViewController.swift
//  Notes
//
//  Created by Артём Харченко on 18.01.2023.
//

import UIKit

protocol NotesListDelegate: AnyObject {
    func refreshNotes()
}

class NoteListViewController: UIViewController {
    
    var allNotes: [Note] = []

    private let plusView = PlusView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchNotes()
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupPlusView()
        setConstraints()
    }
    
    //MARK: - Functions
    private func fetchNotes() {
        StorageManager.shared.fetchNotes { result in
            switch result {
            case .success(let notes):
                self.allNotes = notes
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func indexForNote(id: UUID, in list: [Note]) -> IndexPath {
        let row = Int(list.firstIndex(where: { $0.id == id }) ?? 0)
        return IndexPath(row: row, section: 0)
    }
    
    private func setupNavigationBar() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupPlusView() {
        view.addSubview(plusView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(plusButtonPressed))
        plusView.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func plusButtonPressed() {
        goToEditNote(createNote())
    }
    
    private func goToEditNote(_ note: Note) {
        let noteCreationVC = NoteEditingViewController()
        noteCreationVC.note = note
        noteCreationVC.delegate = self
        navigationController?.pushViewController(noteCreationVC, animated: true)
        
    }
    
    private func createNote() -> Note {
        let note = StorageManager.shared.createNote()
        allNotes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        return note
    }
}

//MARK: - UITableViewDataSource,UITableViewDelegate
extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allNotes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NoteListTableViewCell else { return UITableViewCell() }
        cell.configure(note: allNotes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEditNote(allNotes[indexPath.row])
//        tableView.deselectRow(at: indexPath, animated: true)
//        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .automatic)
//            StorageManager.shared.deleteNote(<#T##note: Note##Note#>) //обдумать удаление
        }
    }
}

//MARK: - Constraints
extension NoteListViewController {
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        plusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusView.widthAnchor.constraint(equalToConstant: 60),
            plusView.heightAnchor.constraint(equalToConstant: 60),
            plusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            plusView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}

//MARK: - UISearchResultsUpdating
extension NoteListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func filterCounterForSearchText(_ searchText: String) {
        
    }
}

//MARK: - ListNotesDelegate
extension NoteListViewController: NotesListDelegate {
    
    func refreshNotes() {
        print(#function)
        allNotes = allNotes.sorted { $0.lastUpdated > $1.lastUpdated }
        tableView.reloadData()
    }
}

