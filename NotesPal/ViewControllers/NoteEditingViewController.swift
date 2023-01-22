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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed)
        )
    }
    
    private func updateTextView() {
        note.text = textView.text
        note.lastUpdated = Date()
        StorageManager.shared.saveContext()
        delegate?.refreshNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    @objc private func donePressed() {
        navigationController?.popViewController(animated: true)
        updateTextView()
    }
    
    private func deleteNote() {
        delegate?.deleteNote(with: note.id)
        StorageManager.shared.delete(note)
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
        } else {
            updateTextView()
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
