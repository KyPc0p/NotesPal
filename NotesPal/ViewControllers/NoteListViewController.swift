//
//  ViewController.swift
//  Notes
//
//  Created by Артём Харченко on 18.01.2023.
//

import UIKit

protocol NotesListDelegate: AnyObject {
    func refreshNotes()
    func deleteNote(with id: UUID)
}

class NoteListViewController: UIViewController {
    
    private var allNotes: [Note] = []
    private var filtredNotes: [Note] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchBarIsEmty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        searchController.isActive && !searchBarIsEmty
    }

    private let plusView = PlusView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: NoteListTableViewCell.identifier)
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
    
    //MARK: - UISetup
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
        searchController.showsSearchResultsController = true  //?
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true //?
    }
    
    //MARK: - Functions
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
        let note = StorageManager.shared.create()
        allNotes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        return note
    }
    
    private func fetchNotes() {
        StorageManager.shared.read { result in
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
}

//MARK: - UITableViewDataSource,UITableViewDelegate
extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredNotes.count
        }
        return allNotes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteListTableViewCell.identifier, for: indexPath) as? NoteListTableViewCell else { return UITableViewCell() }
        
        if isFiltering {
            cell.configure(note: filtredNotes[indexPath.row])
            return cell
        }
        
        cell.configure(note: allNotes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            goToEditNote(filtredNotes[indexPath.row])
        } else {
            goToEditNote(allNotes[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note: Note
            
            if isFiltering {
                note = filtredNotes.remove(at: indexPath.row)
                print("1111111")
            } else {
                print("2222222")
                note = allNotes.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(note)
        }
    }
}

//MARK: - UISearchResultsUpdating
extension NoteListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterCounterForSearchText(searchController.searchBar.text ?? "")
    }
    
    func filterCounterForSearchText(_ searchText: String) {
        filtredNotes = allNotes.filter({ (notes: Note) -> Bool in
            notes.text.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
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

//MARK: - ListNotesDelegate
extension NoteListViewController: NotesListDelegate {
    
    func refreshNotes() {
        allNotes = allNotes.sorted { $0.lastUpdated > $1.lastUpdated }
        tableView.reloadData()
    }
    
    func deleteNote(with id: UUID) {
        let indexPath = indexForNote(id: id, in: allNotes)
        allNotes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
