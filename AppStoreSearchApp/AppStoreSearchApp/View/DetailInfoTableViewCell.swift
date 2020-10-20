//
//  detailInfoTableViewCell.swift
//  AppStoreSearchApp
//
//  Created by isens on 28/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

enum EnumDetailInfoTableViewCellType {
    case str
    case image
    case arrow
}

protocol DetailInfoTableViewCellDelegate {
    // 높이 변경 전달용
    func changedHeight(_ index: Int)
}

class DetailInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var subImageView: UIImageView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var subTitleLabelTrailingConstraint: NSLayoutConstraint!
    
    var delegate: DetailInfoTableViewCellDelegate?
    var index: Int = 0 // cell index
    
    override func awakeFromNib() {
        self.subImageView.isHidden = true
        self.subTitleLabel.isHidden = true
    }
    
    func setType(_ type: EnumDetailInfoTableViewCellType, index: Int, isExpanded: Bool = false) {
        self.index = index
        if type == .str {
            self.subTitleLabel.isHidden = false
            self.subImageView.isHidden = true
            self.arrowButton.isHidden = true
            self.subTitleLabelTrailingConstraint.constant = 0
        } else if type == .image {
            self.subTitleLabel.isHidden = true
            self.subImageView.isHidden = false
            self.arrowButton.isHidden = true
            self.subTitleLabelTrailingConstraint.constant = 0
        } else {
            self.subImageView.isHidden = true
            self.subTitleLabelTrailingConstraint.constant = 28
            
            if isExpanded {
                self.subTitleLabel.isHidden = true
                self.arrowButton.isHidden = true
            } else {
                self.subTitleLabel.isHidden = false
                self.arrowButton.isHidden = false
            }
        }
    }
    
    @IBAction func onTappedArrowButton(_ sender: Any) {
        self.subTitleLabel.isHidden = true
        self.arrowButton.isHidden = true
        self.delegate?.changedHeight(self.index) // 높이 변경
    }
}
