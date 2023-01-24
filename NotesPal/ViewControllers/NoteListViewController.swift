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
    
    private var isFiltering: Bool {
        searchController.isActive
    }

    private let plusView = PlusView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .plain)
        tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: NoteListTableViewCell.identifier)
        return tableView
    }()
    
    static let appFontName = "PingFang HK"
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchNotes()
        isEmptyCheck()
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupPlusView()
        setConstraints()
    }
    
    //MARK: - UISetup
    private func setupNavigationBar() {
        title = "NotesPal"
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: NoteListViewController.appFontName, size: 25)!]
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
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.showsSearchResultsController = true  //?
        searchController.obscuresBackgroundDuringPresentation = false
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
        let note = CoreDataManager.shared.create()
        allNotes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        return note
    }
    
    private func isEmptyCheck() {
        if allNotes.isEmpty {
            let note = CoreDataManager.shared.create(with: "New Note")
            allNotes.insert(note, at: 0)
            tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        }
    }
    
    private func fetchNotes() {
        CoreDataManager.shared.read { result in
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
        65
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
            } else {
                note = allNotes.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            CoreDataManager.shared.delete(note)
        }
    }
}

//MARK: - UISearchResultsUpdating
extension NoteListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterCounterForSearchText(text)
    }
    
    func filterCounterForSearchText(_ searchText: String) {
        filtredNotes = allNotes.filter { $0.text.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}

//MARK: - Constraints
extension NoteListViewController {
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
