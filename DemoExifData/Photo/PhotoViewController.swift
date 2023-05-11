//
//  PhotoViewController.swift
//  DemoExifData
//
//  Created by Andrea Busi on 11/05/23.
//

import UIKit
import PhotosUI


class PhotoViewController: UIViewController {

    private let customView = PhotoView()
    private let service = PhotoService()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Private
    
    private func configureUI() {
        customView.onTapOpenCamera = { [weak self] in
            self?.requestPhotoPermission()
        }
    }
    
    @MainActor
    private func showResult(_ error: Error?) {
        switch error {
        case .some(let error):
            customView.resultImageView.image = UIImage(systemName: "xmark.circle.fill")
            customView.resultImageView.tintColor = .systemRed
            customView.errorLabel.text = error.localizedDescription
        case .none:
            customView.resultImageView.image = UIImage(systemName: "hand.thumbsup.fill")
            customView.resultImageView.tintColor = .systemGreen
            customView.errorLabel.text = nil
        }
    }
    
    private func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.openPhotoPicker()
                }
            } else {
                self.showResult(PhotoService.PhotoError.noPermission)
            }
        }
    }
    
    private func openPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension PhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
   }
   
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      picker.dismiss(animated: true, completion: nil)
            
      elaboratePhoto(from: info)
   }
    
    private func elaboratePhoto(from mediaInfo: [UIImagePickerController.InfoKey : Any]) {
        guard let asset = mediaInfo[.phAsset] as? PHAsset else {
            return
        }
        
        Task.init {
            do {                
                let uuid = UUID().uuidString
                let imageWithExifUrl = service.createLocalUrl(for: uuid + "_exif.png")
                
                // Method A: store locally the image using CIContext method,
                // that will preserve EXIF metadata
                try await service.savePhotoWithExif(asset: asset, localUrl: imageWithExifUrl)
                print("[SUCCESS] EXIF | path: \(imageWithExifUrl)")
                
                // Method B: store locally the image using the `jpegData`,
                // EXIF data will be lost
                let imageWithoutExifUrl = service.createLocalUrl(for: uuid + "_noexif.png")
                try service.savePhotoWithoutExif(info: mediaInfo, localUrl: imageWithoutExifUrl)
                print("[SUCCESS] NO EXIF | path: \(imageWithoutExifUrl)")
                
                showResult(nil)
            } catch {
                showResult(error)
            }
        }
    }
}
