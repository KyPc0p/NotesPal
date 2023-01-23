//
//  NoteEditingViewController.swift
//  NotesPal
//
//  Created by Артём Харченко on 19.01.2023.
//

import UIKit

class NoteEditingViewController: UIViewController {

    var note: Note!
    
    weak var delegate: NotesListDelegate?
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        textView.text = note.text
        setupNavBar()
        setupTextView()
        setConstraints()
    }
    
    //MARK: - Functions
    private func setupTextView() {
        textView.delegate = self
        view.addSubview(textView)
        textView.font = UIFont(name: "Arial", size: 20)
    }
    
    private func setupNavBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed)
        )
        
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash ,
            target: self,
            action: #selector(trashPressed)
        )
        
        navigationItem.rightBarButtonItems = [trashButton, doneButton]
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Delete Note",
            message: "Do you want to delete this Note?",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
          //delete Note
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func updateTextView() {
        note.text = textView.text
        note.lastUpdated = Date()
        StorageManager.shared.saveContext()
        delegate?.refreshNotes()
    }
    
    @objc private func donePressed() {
        updateTextView()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func trashPressed() {
        showAlert()
    }
    
    private func deleteNote() {
        delegate?.deleteNote(with: note.id)
        StorageManager.shared.delete(note)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
//MARK: - UITextViewDelegate
extension NoteEditingViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.text = textView.text
        if note.title.isEmpty {
            deleteNote()
            print("delete Note")
        } else {
            updateTextView()
            print("update Note")
        }
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
