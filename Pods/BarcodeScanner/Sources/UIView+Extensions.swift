import UIKit

extension UIView {
  var viewInsets: UIEdgeInsets {
    if #available(iOS 11, *) {
      return safeAreaInsets
    }
    
    return .zero
  }
}
