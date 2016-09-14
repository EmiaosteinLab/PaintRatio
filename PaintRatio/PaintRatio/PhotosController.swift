//
//  PhotosController.swift
//  PaintRatio
//
//  Created by Emiaostein on 13/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotosController: NSObject {
    
    enum AccessStatus {
        case Enabled(PHFetchResult<PHAsset>)
        case Failture
    }
    
    static let share = PhotosController()
    
    fileprivate let imageCacheManager = PHCachingImageManager()
    fileprivate var accessStatus = AccessStatus.Failture
    fileprivate var removeHandler: ((IndexSet) -> ())?
    fileprivate var insertHandler: ((IndexSet) -> ())?
    fileprivate var changeHandler: ((IndexSet) -> ())?
    fileprivate var moveHandler: ((Int, Int) -> ())?
    fileprivate var reloadHandler: (() -> ())?
    
    func registerPhotoChange() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func startRequestPhotos(completion: @escaping (Bool) -> ()) {
        checkLibraryStatus {[weak self] (scuccess) in
            if scuccess {
                self?.startFetchPhotos()
            }
            completion(scuccess)
        }
    }
    
    func fetchImageAt(i: Int, fillSize: CGSize, completion: @escaping (UIImage?) -> ()) {
        switch accessStatus {
        case .Enabled(let result):
            let asset = result[i]
            let w = asset.pixelWidth
            let h = asset.pixelHeight
            let scale = max(fillSize.width / CGFloat(w), fillSize.height / CGFloat(h))
            let s = UIScreen.main.scale
            let targetSize = CGSize(width: CGFloat(w) * scale * s, height: CGFloat(h) * scale * s)
            let option = PHImageRequestOptions()
            option.resizeMode = .exact
//            option.isSynchronous = true
            imageCacheManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: option, resultHandler: { (image, info) in
                completion(image)
            })
        default:
            completion(nil)
        }
    }
    
    func photoChanged(removed:@escaping (IndexSet) -> (), inserted: @escaping (IndexSet) -> (), changed: @escaping (IndexSet) -> (), moved:@escaping (Int, Int) -> (), reloadData: @escaping () -> ()) {
        removeHandler = removed
        insertHandler = inserted
        changeHandler = changed
        moveHandler = moved
        reloadHandler = reloadData
    }
    
    func saveImageToLibrary(image: UIImage, finishedHandler:((Bool) -> ())?) {
        
        func save(image: UIImage, finishedHandler:((Bool) -> ())?) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) {finishedHandler?($0.0)}
        }
        
//        func openSetting() {
//            // alert to open setting
//            let cancelTitle = "Cancel"
//            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
//            
//            let doneTitle = "OK"
//            let doneAction = UIAlertAction(title: doneTitle, style: .default) { (action) in
//                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
//            }
//            
//            let alertTitle = "Please Allow Access to Your Photos"
//            let message = "This allow Curios to share photos from your library and save photos to your camera roll."
//            let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
//            alert.addAction(cancelAction)
//            alert.addAction(doneAction)
//            
//            presentViewController(alert, animated: true, completion: nil)
//        }
        
        func authorize() {
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    save(image: image, finishedHandler: finishedHandler)
                    
                default:
                    finishedHandler?(false)
                }
            }
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            save(image: image, finishedHandler: finishedHandler)
            
        case .notDetermined:
            authorize()
            
        default:()
//            openSetting()
        }
    }
}

extension PhotosController {
    
    fileprivate func checkLibraryStatus(_ completion: ((Bool) -> ())?) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion?(true)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (requestedStatus) in
                if requestedStatus == .authorized {
                    completion?(true)
                } else {
                    completion?(false)
                }
            })
            
        case .denied, .restricted:
            completion?(false)
        }
    }
    
    fileprivate func startFetchPhotos() {
        let allPhotos = PHFetchOptions()
        let dateSortDescritor = NSSortDescriptor(key: "creationDate", ascending: false)
        allPhotos.sortDescriptors = [dateSortDescritor]
        let result = PHAsset.fetchAssets(with: allPhotos)
        self.accessStatus = .Enabled(result)
    }
}

extension PhotosController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection
        section: Int) -> Int {
        switch accessStatus {
        case .Enabled(let result):
            return result.count
        default:
            return 0
        }
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath)
        
        switch accessStatus {
        case .Enabled(let result):
            let asset = result[indexPath.item]
            let localID = asset.localIdentifier
            cell.restorationIdentifier = localID
            let option = PHImageRequestOptions()
            option.resizeMode = .exact
            let scale = UIScreen.main.scale
            imageCacheManager.requestImage(for: asset, targetSize: CGSize(width: 40 * scale, height: 40 * scale), contentMode: .aspectFill, options: option, resultHandler: { [weak cell] (image, info) in
                DispatchQueue.main.async {
                    guard  cell?.restorationIdentifier == localID, let image = image else { return }
                    if let imageView = cell?.viewWithTag(1000) as? UIImageView {
                        imageView.image = image
                    }
                }
            })
            
            fallthrough
        default:
            return cell
        }
    }
}

extension PhotosController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        switch accessStatus {
        case .Enabled(let result):
            guard let changedDetails = changeInstance.changeDetails(for: result) else {return}
            accessStatus = .Enabled(changedDetails.fetchResultAfterChanges)
            
            if let ri = changedDetails.removedIndexes {
                removeHandler?(ri)
            }
            
            if let ii = changedDetails.insertedIndexes {
                insertHandler?(ii)
            }
            
            if let ci = changedDetails.changedIndexes {
                changeHandler?(ci)
            }
            
            if changedDetails.hasMoves == true, let moveHandler = moveHandler {
                changedDetails.enumerateMoves(moveHandler)
            }

        default:
            ()
        }
    }
}
