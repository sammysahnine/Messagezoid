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

//public var left: CGFloat {
//    return self.frame.origin.x
//}
//public var right: CGFloat {
//    return self.frame.size.width + self.frame.origin.x
//}
