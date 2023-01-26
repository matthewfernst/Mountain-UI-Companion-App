//
//  SessionTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class SessionTableViewCell: UITableViewCell {
    
    static var identifier = "SessionTableViewCell"
    
    private var resortNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        return label
    }()
    
    private var snowboardFigureContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private var snowboardFigureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "figure.snowboarding")?.withTintColor(.secondaryLabel)
        imageView.transform = CGAffineTransform(rotationAngle: .pi / 16)
        return imageView
    }()
    
    private var resortStatsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private var resortDateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var resortDateContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(resortNameLabel)
        contentView.addSubview(snowboardFigureContainer)
        contentView.addSubview(snowboardFigureImageView)
        contentView.addSubview(resortStatsLabel)
        contentView.addSubview(resortDateImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    override func prepareForReuse() {
        resortNameLabel.text = nil
        snowboardFigureImageView.backgroundColor = nil
        resortStatsLabel.text = nil
        resortDateImageView.image = nil
    }
    
    public func configure() {
        resortNameLabel.text = "Steamboat Ski Resort"
        snowboardFigureImageView.tintColor = .secondaryLabel
        resortStatsLabel.text = "| 3 runs | 1H 25M"
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let dateOfSessionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraph
        ]
        
        resortDateImageView.image = "Jan\n2".image(withAttributes: dateOfSessionAttributes, move: .zero)?.withTintColor(.label)
        self.backgroundColor = .secondarySystemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - 12
        resortDateContainer.frame = CGRect(x: 10, y: 6, width: size, height: size)
        
        let imageSize = size / 1.5
        resortDateImageView.frame = CGRect(x: (size - imageSize) / 2, y: (size - imageSize) / 2, width: imageSize, height: imageSize)
        resortDateImageView.center = resortDateContainer.center
        
        resortNameLabel.frame = CGRect(x: 15 + resortDateContainer.frame.size.width,
                                       y: -10,
                                       width: contentView.frame.size.width - 15 - resortDateContainer.frame.size.width,
                                       height: contentView.frame.size.height)
        
        resortStatsLabel.frame = CGRect(x: 40  + resortDateContainer.frame.size.width,
                                        y: 10,
                                        width: contentView.frame.size.width - 15 - resortDateContainer.frame.size.width,
                                        height: contentView.frame.size.height)
        
        snowboardFigureContainer.frame = CGRect(x: resortDateContainer.frame.size.width,
                                                y: 15,
                                                width: size,
                                                height: size)
        
        snowboardFigureImageView.frame = CGRect(x: (size - imageSize) / 2, y: (size - imageSize) / 2, width: 18, height: 18)
        snowboardFigureImageView.center = snowboardFigureContainer.center
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
