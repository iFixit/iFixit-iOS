//
//  GuideCell.m
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

class GuideCell: UITableViewCell {

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        
        self.textLabel?.font = UIFont.systemFontOfSize(14.0)
        self.textLabel?.numberOfLines = 2
        self.textLabel?.adjustsFontSizeToFitWidth = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView?.frame = CGRectMake(5.0, 5.0, 48.0, 36.0)
    }

}
