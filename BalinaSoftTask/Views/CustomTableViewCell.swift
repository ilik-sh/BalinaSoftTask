//
//  CustomTableViewCell.swift
//  BalinaSoftTask
//
//  Created by Ilya on 24.08.22.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    static let identifier = "CustomCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        setupTextView()
        setupPhotoImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
    }
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray4
        textView.layer.cornerRadius = 5
        textView.isUserInteractionEnabled = false
        textView.font = .boldSystemFont(ofSize: 14)
        textView.textAlignment = .center
        textView.textAlignment = .justified
        return textView
    }()
    
    private func setupTextView() {
        self.contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
    }
    
    private func setupPhotoImageView() {
        self.contentView.addSubview(photoImageView)
        photoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(textView.snp.height)
            make.height.equalTo(textView.snp.height)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    func setTitle(_ title: String) {
        textView.text = title
    }
    
    func setImage(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        photoImageView.image = image
    }
}
