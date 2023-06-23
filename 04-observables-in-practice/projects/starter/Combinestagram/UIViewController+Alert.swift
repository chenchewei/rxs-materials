//
//  UIViewController+Alert.swift
//  Combinestagram
//
//  Created by Anderson Chen on 2023/6/23.
//  Copyright © 2023 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
  func showAlert(_ title: String, description: String? = nil) -> Completable {
    return Completable.create { [weak self] completable in
      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
        completable(.completed)
      }))
      
      self?.present(alert, animated: true, completion: nil)
      return Disposables.create {
        self?.dismiss(animated: true)
      }
    }
  }
}
