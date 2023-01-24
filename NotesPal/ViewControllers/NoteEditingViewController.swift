//
//  NoteEditingViewController.swift
//  NotesPal
//
//  Created by Артём Харченко on 19.01.2023.
//

import UIKit

class NoteEditingViewController: UIViewController, UIGestureRecognizerDelegate {

    var note: Note!
    
    weak var delegate: NotesListDelegate?
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        return textView
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupTextView()
        setUpGesture()
        setConstraints()
    }
    
    //MARK: - Functions
    private func setupTextView() {
        textView.text = note.text
        view.addSubview(textView)
        textView.font = UIFont(name: NoteListViewController.regularFont, size: 20)
    }
    
    private func setupNavBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.backward"),
            style: .plain,
            target: self,
            action: #selector(finalNoteCheck)
        )
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonPressed)
        )
        
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash ,
            target: self,
            action: #selector(trashButtonPressed)
        )
        trashButton.tintColor = .red
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = [trashButton, doneButton]
    }
    
    private func setUpGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(finalNoteCheck))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Deleting Note",
            message: "Do you want to delete this Note?",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.deleteNote()
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
        CoreDataManager.shared.saveContext()
        delegate?.refreshNotes()
    }
    
    @objc private func doneButtonPressed() {
        textView.endEditing(true)
    }
    
    @objc private func trashButtonPressed() {
        showAlert()
    }
    
    private func deleteNote() {
        delegate?.deleteNote(with: note.id)
        CoreDataManager.shared.delete(note)
    }
    
    @objc func finalNoteCheck() {
        note.text = textView.text
        
        if note.title.isEmpty {
            deleteNote()
        } else {
            updateTextView()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if note.title.isEmpty {
            textView.becomeFirstResponder()
        }
    }
}

extension NoteEditingViewController: UITextViewDelegate {
    
}

//MARK: - Constraints
extension NoteEditingViewController {
    private func setConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16)
        ])
    }
}
