import Foundation

extension DispatchQueue {
  
  class func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + delay,
      execute: closure
    )
  }
  
}
