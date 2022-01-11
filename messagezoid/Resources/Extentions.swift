//
//  Extentions.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import Foundation
import UIKit

extension UIView {
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var width: CGFloat {
        return self.frame.size.width
    }
    public var top: CGFloat {
        return self.frame.origin.y
    }
    public var bottom: CGFloat {
        return self.frame.height + self.frame.origin.y
    }
}

//Public Variables to help increase code efficiency: https://riptutorial.com/ios/example/13778/uiview-extension-for-size-and-frame-attributes

extension UIViewController{
    func centerTitle(){
        for navItem in(self.navigationController?.navigationBar.subviews)! {
             for itemSubView in navItem.subviews {
                 if let largeLabel = itemSubView as? UILabel {
                    largeLabel.center = CGPoint(x: navItem.bounds.width/2, y: navItem.bounds.height/2)
                    return;
                 }
             }
        }
    }
}

//To center my titles: https://stackoverflow.com/questions/57245055/how-to-center-a-large-title-in-navigation-bar-in-the-middle/66366871

extension UIColor {

    convenience init(rgb: UInt) {
        self.init(rgb: rgb, alpha: 1.0)
    }

    convenience init(rgb: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}

var MessagezoidBlue = UIColor(red: 0.149, green: 0.4706, blue: 0.6353, alpha: 1.0)
var MessagezoidPurple = UIColor(red: 0.8745, green: 0.7608, blue: 0.8863, alpha: 1.0)

//For custom colours: https://stackoverflow.com/questions/35073272/button-text-uicolor-from-hex-swift




//public var left: CGFloat {
//    return self.frame.origin.x
//}
//public var right: CGFloat {
//    return self.frame.size.width + self.frame.origin.x
//}


extension UIViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

//Hides keyboard when return is pressed: https://stackoverflow.com/a/57217342

