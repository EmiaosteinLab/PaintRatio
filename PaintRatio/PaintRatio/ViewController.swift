//
//  ViewController.swift
//  PaintRatio
//
//  Created by Emiaostein on 13/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var ruleView: RuleView!
    @IBOutlet weak var thumbnailView: UIVisualEffectView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    weak var photosController: PhotosController! = PhotosController.share
    @IBOutlet weak var scrollView: UIScrollView!
    var canvas: CanvasView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        updateTo(skin: Skin.current, animated: false)
        canvas = Bundle.main.loadNibNamed("CanvasView",
                                          owner: nil,
                                          options: nil)?.first as! CanvasView
        scrollView.addSubview(canvas)
        photoCollectionView.dataSource = photosController
        
        photosController.photoChanged(removed: {[weak self] (set) in
            let indexs = set.map{IndexPath(item: $0, section: 0)}
            self?.photoCollectionView.deleteItems(at: indexs)
            
            }, inserted: {[weak self] (set) in
                let indexs = set.map{IndexPath(item: $0, section: 0)}
                self?.photoCollectionView.insertItems(at: indexs)
                
            }, changed: {[weak self] (set) in
                let indexs = set.map{IndexPath(item: $0, section: 0)}
                self?.photoCollectionView.reloadItems(at: indexs)
                
            }, moved: {[weak self] (i, j) in
                self?.photoCollectionView.moveItem(at: IndexPath(item: i, section: 0), to: IndexPath(item: j, section: 0))
            }) { [weak self] in
                self?.photoCollectionView.reloadData()
        }
        
        photosController.startRequestPhotos {[weak self] (scucess) in
            if scucess {
                DispatchQueue.main.async {
                    self?.photoCollectionView.reloadData()
                    self?.fetchImageAt(i: 0, animated: false)
                }
                
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func fetchImageAt(i: Int, animated: Bool = false) {
        photosController.fetchImageAt(i: i, fillSize: view.bounds.size) { (image) in
            DispatchQueue.main.async {[weak self] in
                if let image = image, let sf = self {
                    self?.canvas.bounds.size = image.size
                    let scale = min(sf.view.bounds.width / image.size.width, sf.view.bounds.height / image.size.height)
                    self?.scrollView.setZoomScale(scale, animated: animated)
                    self?.canvas.frame.origin = CGPoint.zero
                }
                self?.canvas.image = image
            }
        }
    }

}

// MARK: - IBAction
extension ViewController {
    
    @IBAction func changeRule(_ sender: AnyObject) {
        ruleView.changeRule()
    }
    
    @IBAction func camera(_ sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        if navigationController!.isNavigationBarHidden {
            navigationController?.setNavigationBarHidden(false, animated: true)
            thumbnailView.transform = CGAffineTransform.init(translationX: 0, y: 60)
            UIView.animate(withDuration: 0.2, animations: {
                self.thumbnailView.transform = CGAffineTransform.identity
            })
        } else {
            navigationController?.setNavigationBarHidden(true, animated: true)
            self.thumbnailView.transform = CGAffineTransform.identity
            UIView.animate(withDuration: 0.2, animations: {
                self.thumbnailView.transform = CGAffineTransform.init(translationX: 0, y: 60)
                
            })
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
    
    private func centerContent() {
        
        let w = scrollView.bounds.width
        let sw = scrollView.contentSize.width
        let h = scrollView.bounds.height
        let sh = scrollView.contentSize.height

        let left = (w - sw) * 0.5
        let top = (h - sh) * 0.5
        scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fetchImageAt(i: indexPath.item)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            saveImage(img, compeletion: {
                DispatchQueue.main.async {[weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            
        }
    }
}

// MARK: - filePrivate Methods
extension ViewController {
    func saveImage(_ img: UIImage, compeletion: @escaping () -> ()) {
        photosController.saveImageToLibrary(image: img) { (success) in
            if success {
                print("Save image success!")
            }
            compeletion()
        }
    }
}
