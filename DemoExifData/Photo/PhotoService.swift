//
//  PhotoViewModel.swift
//  DemoExifData
//
//  Created by Andrea Busi on 11/05/23.
//

import UIKit
import Photos


class PhotoService {
    enum PhotoError: Error, LocalizedError {
        case noPermission
        case missingImageData
        case invalidImage
        case saveFailed
        
        var errorDescription: String? {
            switch self {
            case .noPermission: return "You need to grant permission to access your camera roll"
            case .missingImageData: return "Missing required image data"
            case .invalidImage: return "Unable to elaborate provided image"
            case .saveFailed: return "Save image failed"
            }
        }
    }
    
    // MARK: - APIs
    
    func createLocalUrl(
        for name: String
    ) -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let url = cacheDirectory.appendingPathComponent(name)
        return url
    }
    
    func savePhotoWithoutExif(
        info: [UIImagePickerController.InfoKey : Any],
        localUrl: URL
    ) throws {
        guard let image = info[.originalImage] as? UIImage else {
            throw PhotoError.missingImageData
        }
        
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            throw PhotoError.invalidImage
        }
        
        do {
            try data.write(to: localUrl)
        } catch {
            throw PhotoError.saveFailed
        }
    }
    
    func savePhotoWithExif(
       asset: PHAsset,
       localUrl: URL
    ) async throws {
       return try await withCheckedThrowingContinuation { continuation in
          // create request to get all asset metadata
          let options = PHContentEditingInputRequestOptions()
           // download from iCloud if necessary
          options.isNetworkAccessAllowed = true
          asset.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
             guard let contentEditingInput else {
                print("[ERROR] Unable to get PHContentEditingInput")
                continuation.resume(throwing: PhotoError.missingImageData)
                return
             }
             guard let imageUrl = contentEditingInput.fullSizeImageURL,
                   let fullImage = CIImage(contentsOf: imageUrl, options: [ .applyOrientationProperty: true ]),
                   let colorSpace = fullImage.colorSpace else {
                print("[ERROR] Unable to create required parameters")
                continuation.resume(throwing: PhotoError.invalidImage)
                return
             }
             
             do {
                try CIContext().writeJPEGRepresentation(of: fullImage,
                                                        to: localUrl,
                                                        colorSpace: colorSpace)
                continuation.resume(returning: ())
             } catch {
                print("[ERROR] Unable to write image (\(error.localizedDescription))")
                continuation.resume(throwing: PhotoError.saveFailed)
             }
          }
       }
    }
}
