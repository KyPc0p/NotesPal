//
//  NoteListTableViewCell.swift
//  NotesPal
//
//  Created by Артём Харченко on 20.01.2023.
//

import UIKit

class NoteListTableViewCell: UITableViewCell {

    let title: UILabel = {
        let title = UILabel()
        title.font
        return title
    }()

    let descriprion: UILabel = {
        let descriprion = UILabel()
        return descriprion
    }()

    func configure(note: Note) {
        addSubview(title)
        addSubview(descriprion)
        title.text = note.title
        descriprion.text = note.desc
        setConstraints()
    }

}

// MARK: - Constaints
extension NoteListTableViewCell {
    private func setConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
        
        descriprion.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriprion.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            descriprion.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            descriprion.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
}
