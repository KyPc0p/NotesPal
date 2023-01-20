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
        return title
    }()

    let descriprion: UILabel = {
        let descriprion = UILabel()
        return descriprion
    }()

    func configure(note: Note) {
        title.text = note.title
        descriprion.text = note.desc
    }

}
