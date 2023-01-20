//
//  NoteEditingViewController.swift
//  NotesPal
//
//  Created by Артём Харченко on 19.01.2023.
//

import UIKit

class NoteEditingViewController: UIViewController {

    var note = Note()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        //настроить
        return textView
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = note.text
        view.backgroundColor = .white
        setupNavBar()
        setupTextView()
        setConstraints()
    }
    
    //MARK: - Functions
    private func setupTextView() {
        view.addSubview(textView)
        textView.font = UIFont(name: "Arial", size: 20)
    }
    
    private func updateTextView() {
        note.lastUpdated = Date()
        StorageManager.shared.saveContext()
        //delegate.refreshNotes()
    }
    
    private func deleteNote() {
//        delegate.deleteNote(with: note.id)
//        StorageManager.shared.deleteNote(note)
    }
    
    private func setupNavBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed)
        )
    }
    
    @objc private func donePressed() {
        navigationController?.popViewController(animated: true)
    }
    
}
//MARK: - UITextViewDelegate
extension NoteEditingViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.text = textView.text
//        if note.title.isEmpty ?? true { мб текст? а не тайтл
//            deleteNotes()
//        } else {
//            updateNotes()
//        }
    }
}

//MARK: - Constraints
extension NoteEditingViewController {
    private func setConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10)
        ])
    }
}
