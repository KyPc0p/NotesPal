//
//  NoteEditingViewController.swift
//  NotesPal
//
//  Created by Артём Харченко on 19.01.2023.
//

import UIKit

class NoteEditingViewController: UIViewController {

    var note: Note!
    private var isDone = false
    weak var delegate: NotesListDelegate?
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        return textView
    }()
    
    //MARK: - ViewDidLoad/VCLife
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTextView()
        setUpGesture()
        registerKeyboardNotifications()
        setConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if note.title.isEmpty {
            textView.becomeFirstResponder()
        }
    }
    
    //MARK: - UISetup 
    private func setupTextView() {
        textView.text = note.text
        textView.textColor = UIColor(named: "descriptionColor")
        textView.font = UIFont(name: Fonts.regularFont, size: 18)
        textView.autocorrectionType = .no
        textView.tintColor = .systemRed
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 10)
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        view.addSubview(textView)
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
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(doneButtonPressed)
        )
        doneButton.tintColor = UIColor(named: "textColor")
        doneButton.title = isDone ? "Edit" : "Done"
        
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash ,
            target: self,
            action: #selector(showTrashButtonAlert)
        )
        trashButton.tintColor = .systemRed
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = [trashButton, doneButton]
    }
    
    //MARK: - AlertController
    @objc private func showTrashButtonAlert() {
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
    
    //MARK: - Logic fucntions
    private func updateTextView() {
        note.text = textView.text
        note.lastUpdated = Date()
        CoreDataManager.shared.saveContext()
        delegate?.refreshNotes()
    }
    
    @objc private func doneButtonPressed() {
        isDone.toggle()
        DispatchQueue.main.async {
            self.setupNavBar()
        }
        textView.isEditable.toggle()
        textView.endEditing(true)
    }
    private func deleteNote() {
        delegate?.deleteNote(with: note.id)
        CoreDataManager.shared.delete(note)
    }
    
    @objc private func finalNoteCheck() {
        note.text = textView.text
        
        if note.title.isEmpty {
            deleteNote()
        } else {
            updateTextView()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Gestures
    private func setUpGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(finalNoteCheck))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
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
