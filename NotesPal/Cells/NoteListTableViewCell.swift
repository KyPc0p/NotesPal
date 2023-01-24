//
//  NoteListTableViewCell.swift
//  NotesPal
//
//  Created by Артём Харченко on 20.01.2023.
//

import UIKit

class NoteListTableViewCell: UITableViewCell {
    
    static let identifier = "NoteListTableViewCell"

    private let title: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: Fonts.mediumFont, size: 18)
        title.textColor = UIColor(named: "textColor")
        return title
    }()

    private let descriprion: UILabel = {
        let descriprion = UILabel()
        descriprion.font = UIFont(name: Fonts.regularFont, size: 16)
        descriprion.textColor = UIColor(named: "descriptionColor")
        
        return descriprion
    }()
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(title)
        addSubview(descriprion)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    func configure(note: Note) {
        title.text = note.title
        descriprion.text = note.titleDescription
    }
}

// MARK: - Consrtaints
extension NoteListTableViewCell {
    private func setConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
        
        descriprion.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriprion.topAnchor.constraint(equalTo: title.bottomAnchor),
            descriprion.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriprion.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
    }
}
