//
//  ViewController.swift
//  PaintRatio
//
//  Created by Emiaostein on 13/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var thumbnailView: UIVisualEffectView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet var photosController: PhotosController! = PhotosController.share
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
