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
        registerKeyboardNotifications()
        setConstraints()
    }
    
    //MARK: - Functions
    private func setupTextView() {
        textView.text = note.text
        textView.tintColor = .systemRed
        textView.autocorrectionType = .no
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 10)
        textView.dataDetectorTypes = [.link, .phoneNumber]
        
//        textView.isEditable = false //что делать?
        textView.isSelectable = true
        
        textView.allowsEditingTextAttributes = true
        textView.textColor = UIColor(named: "descriptionColor")
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
        backButton.tintColor = UIColor(named: "textColor")
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonPressed)
        )
        doneButton.tintColor = UIColor(named: "textColor")
        
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash ,
            target: self,
            action: #selector(trashButtonPressed)
        )
        trashButton.tintColor = .systemRed
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = [trashButton, doneButton]
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Do you want to delete this Note?",
            message: nil,
            preferredStyle: .alert
        )
        alert.view.tintColor = UIColor(named: "textColor")
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.deleteNote()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func setUpGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(finalNoteCheck))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
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
    
    //MARK: - Notifications
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(upadateTextView),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(upadateTextView),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func upadateTextView(_ notification: Notification) {
        let userInfo = notification.userInfo
        let getKeyboardSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardFrame = self.view.convert(getKeyboardSize, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
//        self.textView.contentOffset = CGPoint.zero
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
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
