/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  
  private var bag = DisposeBag()
  private let images = BehaviorRelay<[UIImage]>(value: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    images
      .subscribe(onNext: { [weak self] photos in
        guard let self, let preview = imagePreview else { return }
        preview.image = photos.collage(size: preview.frame.size)
        updateUI(photos: photos)
      })
      .disposed(by: bag)
  }
  
  @IBAction func actionClear() {
    images.accept([])
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    PhotoWriter.singleSave(image)
      .subscribe { [weak self] id in
        self?.showMessage("Saved with id: \(id)")
      } onFailure: { [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
      }
      .disposed(by: bag)

  }

  @IBAction func actionAdd() {
    
    let photosVC = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    
    photosVC.selectedPhotos
      .subscribe(onNext: { [weak self] newImage in
        guard let self else { return }
        let newImages = images.value + [newImage]
        images.accept(newImages)
      }, onDisposed: {
        print("Completed photo selection")
      })
      .disposed(by: bag)
    navigationController?.pushViewController(photosVC, animated: true)
  }

  func showMessage(_ title: String, description: String? = nil) {
    showAlert(title, description: description)
      .subscribe()
      .disposed(by: bag)
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = !photos.isEmpty && photos.count.isMultiple(of: 2)
    buttonClear.isEnabled = !photos.isEmpty
    itemAdd.isEnabled = photos.count < 6
    title = photos.isEmpty ? "Collage" : "\(photos.count) photos"
    
  }
}
