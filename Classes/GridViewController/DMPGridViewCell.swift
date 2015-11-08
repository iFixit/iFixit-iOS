//
//  DMPGridViewCell.m
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

import UIKit

enum DMPGridViewCellStyle: Int {
    case Portrait1 = 0
    case Portrait2
    case Portrait3
    case Portrait4
    case Landscape1
    case Landscape2
    case Landscape3
    case Landscape4
    case PortraitColumns
    case LandscapeColumns
}

class DMPGridViewCell : UIView {

    var style: DMPGridViewCellStyle
    var index: Int = 0
    var delegate: DMPGridViewDelegate?
    
    var imageView: UIImageView!
    var textLabel: UILabel!

    class func cellsPerRowForStyle(style:DMPGridViewCellStyle) -> Int {
        var result = 0
        
        switch (style) {
            case .Portrait1:
                result = 2

            case .Portrait2:
                result = 2

            case .Portrait3:
                result = 2

            case .Portrait4:
                result = 3

            case .Landscape1:
                result = 3

            case .Landscape2:
                result = 2

            case .Landscape3:
                result = 3

            case .Landscape4:
                result = 3

            case .PortraitColumns:
                result = 2

            case .LandscapeColumns:
                result = 2
        }
        
        return result
    }

    func pickFrame() -> CGRect {
        var frame:CGRect
        
        switch (style, index) {
            case (.Portrait1, 0):
                frame = CGRectMake( 10.0, 10.0, 300.0, 225.0)
            case (.Portrait1, 1):
                frame = CGRectMake(320.0, 10.0, 440.0, 225.0)
                
            case (.Portrait2, 0):
                frame = CGRectMake( 10.0, 10.0, 440.0, 225.0)
            case (.Portrait2, 1):
                frame = CGRectMake(460.0, 10.0, 300.0, 225.0)
                
            case (.Portrait3, 0):
                frame = CGRectMake( 10.0, 10.0, 370.0, 225.0)
            case (.Portrait3, 1):
                frame = CGRectMake(390.0, 10.0, 370.0, 225.0)
                
            case (.Portrait4, 0):
                frame = CGRectMake( 10.0, 10.0, 243.0, 225.0)
            case (.Portrait4, 1):
                frame = CGRectMake(263.0, 10.0, 243.0, 225.0)
            case (.Portrait4, 2):
                frame = CGRectMake(516.0, 10.0, 244.0, 225.0)

            case (.Landscape1, 0):
                frame = CGRectMake( 10.0, 10.0, 280.0, 225.0)
            case (.Landscape1, 1):
                frame = CGRectMake(300.0, 10.0, 424.0, 225.0)
            case (.Landscape1, 2):
                frame = CGRectMake(734.0, 10.0, 280.0, 225.0)

            case (.Landscape2, 0):
                frame = CGRectMake( 10.0, 10.0, 497.0, 225.0)
            case (.Landscape2, 1):
                frame = CGRectMake(517.0, 10.0, 497.0, 225.0)

            case (.Landscape3, 0):
                frame = CGRectMake( 10.0, 10.0, 328.0, 225.0)
            case (.Landscape3, 1):
                frame = CGRectMake(348.0, 10.0, 328.0, 225.0)
            case (.Landscape3, 2):
                frame = CGRectMake(686.0, 10.0, 328.0, 225.0)

            case (.Landscape4, 0):
                frame = CGRectMake( 10.0, 10.0, 328.0, 225.0)
            case (.Landscape4, 1):
                frame = CGRectMake(348.0, 10.0, 328.0, 225.0)
            case (.Landscape4, 2):
                frame = CGRectMake(686.0, 10.0, 328.0, 225.0)
                
            case (.PortraitColumns, 0):
                frame = CGRectMake( 10.0, 10.0, 369.0, 225.0)
            case (.PortraitColumns, 1):
                frame = CGRectMake(389.0, 10.0, 369.0, 225.0)

            case (.LandscapeColumns, 0):
                frame = CGRectMake( 10.0, 10.0, 337.0, 225.0)
            case (.LandscapeColumns, 1):
                frame = CGRectMake(357.0, 10.0, 337.0, 225.0)

            default:
                frame = CGRectMake(10.0, 10.0, 300.0, 225.0)
        }
        
        return frame
    }

    init(style:DMPGridViewCellStyle, index:Int) {
        
        self.style = style
        self.index = index
        
        super.init(frame:CGRectMake(10.0, 10.0, 300.0, 225.0))

        self.frame = self.pickFrame()
        self.setupView()
        
        // Add a drop shadow.
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 1
        self.layer.shadowPath = UIBezierPath(rect:self.bounds).CGPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        // Image
        self.imageView = UIImageView(frame:CGRectMake(0.0, 0.0, width, height))
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        // Title
        let overlayView = UIView(frame:CGRectMake(0.0, 175.0, width, 50.0))
        overlayView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.5)
        self.textLabel = UILabel(frame:CGRectMake(10.0, 5.0, width - 20.0, 40.0))
        textLabel.font = UIFont.boldSystemFontOfSize(16.0)
        textLabel.textColor = UIColor.whiteColor()
        textLabel.backgroundColor = UIColor.clearColor()
        
        overlayView.addSubview(textLabel)
        self.addSubview(overlayView)
    }

}
