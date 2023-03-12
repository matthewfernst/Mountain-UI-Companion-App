//
//  NameProfileTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import UIKit

class NameTableViewCell: UITableViewCell {

    static let identifier = "NameTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let firstNameTextField: UITextField = {
        return UITextField()
    }()
    
    private let lastNameTextField: UITextField = {
        return UITextField()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(firstNameTextField)
        contentView.addSubview(lastNameTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(name: String) {
        let fullName = name.components(separatedBy: " ")
        firstNameTextField.text = fullName[0]
        lastNameTextField.text = fullName[1]
        
        self.backgroundColor = .secondarySystemBackground
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size =  contentView.frame.size.height
        
        nameLabel.frame = CGRect(x: 20, y: 0, width: size + 3, height: size)
        
        firstNameTextField.frame = CGRect(x: nameLabel.frame.midX + 40, y: 0, width: size * 2, height: size)
        
        lastNameTextField.frame = CGRect(x: firstNameTextField.frame.midX + 60, y: 0, width: size * 2, height: size)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
