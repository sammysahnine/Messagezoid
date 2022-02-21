//
//  ChatTableViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 03/02/2022.
//

import SDWebImage
import UIKit
import SDWebImage

class ChatsTableViewCell: UITableViewCell {

    static let cellid = "ChatsTableViewCell"
    
    private let imageViewPFP: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let displayName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let recentMessage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(imageViewPFP)
            contentView.addSubview(displayName)
            contentView.addSubview(recentMessage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageViewPFP.frame = CGRect(x: 10, y: 10, width: 90, height: 90)
        displayName.frame = CGRect(x: imageViewPFP.right + 10, y: 10, width: contentView.width - imageViewPFP.width, height: (contentView.height-40)/2)
        recentMessage.frame = CGRect(x: imageViewPFP.right + 10, y: displayName.bottom, width: contentView.width - imageViewPFP.width - 15, height: (contentView.height-20)/2)
    }
    
    public func configure(with model: Chat) {
        self.recentMessage.text = model.recentMessage.content
        self.displayName.text = model.otherName
        
        let url = "ProfilePic/images/\(model.otherUID)_profilepic.png"
        StorageManager.shared.downloadURL(for: url, completion: { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.imageViewPFP.sd_setImage(with: url, completed: nil)
                    //Downloads, sets and caches
                }
            case .failure(_):
                print(url)
                print("get image fail")
            }
        
        })
    }
}

