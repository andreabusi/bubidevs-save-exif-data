//
//  PhotoView.swift
//  DemoExifData
//
//  Created by Andrea Busi on 11/05/23.
//

import UIKit


class PhotoView: UIView {
    
    var onTapOpenCamera: () -> Void = { }
    
    // MARK: - UI
    
    private lazy var openCameraButton: UIButton = {
        let button = UIButton(configuration: .borderedProminent(), primaryAction: .init(title: "Open camera roll", handler: { [weak self] _ in
            self?.onTapOpenCamera()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemRed
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubview(openCameraButton)
        addSubview(resultImageView)
        addSubview(errorLabel)
        
        openCameraButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        openCameraButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        resultImageView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        resultImageView.widthAnchor.constraint(equalTo: resultImageView.heightAnchor).isActive = true
        resultImageView.centerXAnchor.constraint(equalTo: openCameraButton.centerXAnchor).isActive = true
        resultImageView.topAnchor.constraint(equalTo: openCameraButton.bottomAnchor, constant: 20.0).isActive = true
        
        errorLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        errorLabel.topAnchor.constraint(equalTo: resultImageView.bottomAnchor, constant: 20.0).isActive = true
    }
}
