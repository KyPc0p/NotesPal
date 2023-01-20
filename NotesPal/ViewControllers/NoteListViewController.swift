//
//  ViewController.swift
//  Notes
//
//  Created by Артём Харченко on 18.01.2023.
//

import UIKit

class NoteListViewController: UIViewController {
    
    var allNotes: [Note] = [] //убрать отсюда, будет все стирать каждый раз?

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
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupPlusView()
        setConstraints()
//        fetchNotes()
    }
    
    //MARK: - Functions
    private func fetchNotes() {
        allNotes = StorageManager.shared.fetchNotes()
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(createNote))
        plusView.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

//MARK: - UITableViewDataSource,UITableViewDelegate
extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NoteListTableViewCell else { return UITableViewCell() }
//        cell.configure(note: <#T##Note#>)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .automatic)
//            StorageManager.shared.deleteNote(<#T##note: Note##Note#>) //обдумать удаление
        }
    }
    
    @objc private func createNote() -> Note {
        let note = StorageManager.shared.createNote()
        let NoteCreationVC = NoteEditingViewController() //должен быть тут этот переход?
        
        allNotes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
        
        navigationController?.pushViewController(NoteCreationVC, animated: true)
        return note
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

