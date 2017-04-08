//
//  Constants.swift
//  EngineeringDesk
//
//  Created by Alejandro Silveyra on 10/17/15.
//  Copyright © 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit





extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
}





enum Precedence: Int {
    case Dummy
    case Number
    case Variable
    case Special
    case Multiply,Divide
    case Plus
    case Minus
}

enum TypeOfBlock: Int {
    case Glow
    case Number //color light grey
    case Operator //color blue
    case Special // color seagreen
    case ExtraEquation // color yellow
    case Symbol // color dark grey
    //unused color red
}

struct Constants {
    struct dimensions {
        struct AllPad {
            static let width : CGFloat = 251
            static let height : CGFloat = 724
        }
        struct Paper {
            static let width : CGFloat = 1275
            static let height : CGFloat = 1650
        }
    }
    struct pad {
        struct colors {
            static let gray : UIColor =
            UIColor.init(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
            static let grayBlue: UIColor = UIColor.init(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)

        }
    }

    struct block {
        static let fontSize : CGFloat = 20.0
        static let fontWidthPadding : CGFloat = 15.0
        static let height : CGFloat = 30.0
        static let cornerRadius : CGFloat = 7.0
        struct colors {
            static let green : UIColor = UIColor.init(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0)
            static let lighterGray : UIColor = UIColor.init(red: 228/255, green: 229/255, blue: 229/255, alpha: 1.0)
            static let def : UIColor = UIColor.init(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
            static let blue : UIColor = UIColor.init(red: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
            static let gray: UIColor = UIColor.init(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
        }
    }
}
