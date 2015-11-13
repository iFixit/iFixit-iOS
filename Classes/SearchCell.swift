//
//  SearchCell.m
//  iFixit
//
//  Created by Stefan Ayala on 11/16/13.
//
//

class SearchCell: UITableViewCell {

    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {

        super.init(style:style, reuseIdentifier:reuseIdentifier)
        
        // Initialization code
        textLabel?.font = UIFont.systemFontOfSize(14.0)
        textLabel?.numberOfLines = 2
        textLabel?.adjustsFontSizeToFitWidth = true
}

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func setSelected(selected:Bool, animated:Bool) {
        super.setSelected(selected, animated:animated)
        // Configure the view for the selected state
    }

}
