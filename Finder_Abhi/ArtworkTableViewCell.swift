//
//  ArtworkTableViewCell.swift
//  Finder_Abhi
//
//  Created by BALAJI ABHISHEK on 1/17/19.
//  Copyright © 2019 BALAJI ABHISHEK. All rights reserved.
//

import UIKit

//This class is custom table view cell which is getting embedded to SearchTableView.
class ArtworkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var lblTrackName: UILabel!
    @IBOutlet weak var lblDescOrUrl: UILabel!
    @IBOutlet weak var imgArtwork: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
