//
//  SearchResultTableTableCell.swift
//  AppStoreSearchApp
//
//  Created by isens on 28/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var userRatingCountLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var artworkUrlImage: UIImageView!
    @IBOutlet var averageUserRatingImages: [UIImageView]!
    @IBOutlet var screenshotUrlImages: [UIImageView]!
    
    override func awakeFromNib() {
        // init artworkUrlImage UI
        self.artworkUrlImage.layer.cornerRadius = 15.0
        self.artworkUrlImage.layer.masksToBounds = true
        self.artworkUrlImage.layer.borderWidth = 1.0
        self.artworkUrlImage.layer.borderColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(240.0/255.0), blue: CGFloat(240.0/255.0), alpha: CGFloat(1.0)).cgColor
        
        // init screenshotUrlImages UI
        for screenshotUrlImage in self.screenshotUrlImages {
            screenshotUrlImage.layer.cornerRadius = 10.0
            screenshotUrlImage.contentMode = .scaleAspectFill
        }
        
        // init button UI
        self.openButton.layer.cornerRadius = 15.0
    }

    func setArtworkUrlImage(_ imageUrlString: String) {
        if let url = URL(string: imageUrlString) {
            do {
                let data = try Data(contentsOf: url)
                self.artworkUrlImage.image = UIImage(data: data)
            } catch {
                print("setArtworkUrlImage error: \(error.localizedDescription)")
            }
        }
    }
    
    func setAverageUserRating(_ averageUserRating: Double) {
        for imageView in self.averageUserRatingImages {
            imageView.image = UIImage(systemName: "star")
        }
        for i in 0..<Int(round(averageUserRating)) {
           self.averageUserRatingImages[i].image = UIImage(systemName: "star.fill")
        }
    }
    
    func setScreenshotUrlImages(_ imageUrls: [String]) {
        for (index, imageUrlString) in imageUrls.enumerated() {
            if index >= self.screenshotUrlImages.count { // 이미지들 중 3개만 표시하기 위함
                break
            }
            if let url = URL(string: imageUrlString) {
                do {
                    let data = try Data(contentsOf: url)
                    self.screenshotUrlImages[index].image = UIImage(data: data)
                } catch {
                    print("setScreenshotUrlImages error: \(error.localizedDescription)")
                }
            }
        }
    }
}
