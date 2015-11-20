//
//  LocationTableViewCell.swift
//  Current
//
//  Created by Chase Roossin on 11/18/15.
//  Copyright © 2015 RoossinEnterprise. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var locationImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func loadCell(location: Location) {
        titleLabel.text = location.title
        infoLabel.text = location.info
        distanceLabel.text = "\(String(location.distance)) mi"
        locationImg.image = UIImage(named: "icon-food")
    }
}
