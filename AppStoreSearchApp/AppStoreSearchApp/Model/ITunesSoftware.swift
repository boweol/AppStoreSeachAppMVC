//
//  ITunesSoftware.swift
//  AppStoreSearchApp
//
//  Created by isens on 29/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//
// iTunes 객체 모델

import Foundation

class ITunesSoftware {
    var screenshotUrls: [String]?
    var artworkUrl60: String?
    var artworkUrl100: String?
    var artworkUrl512: String?
    var artistViewUrl: String?
    var minimumOsVersion: String?
    var trackName: String?
    var currentVersionReleaseDate: String?
    var sellerName: String?
    var trackCensoredName: String?
    var languageCodesISO2A: [String]? {
        didSet {
            if let codes = languageCodesISO2A {
                var lanString = ""
                for (index, code) in codes.enumerated() {
                    lanString += code
                    if index < codes.count - 1 {
                        lanString += ", "
                    }
                }
                self.languageCodesISO2AString = lanString
            }
        }
    }
    var languageCodesISO2AString: String?
    var fileSizeBytes: String? {
        didSet {
            if let fsb = self.fileSizeBytes {
                var fileSizeBytesFloat: Float = Float(fsb)!
                var fsbString: String = ""
                if fileSizeBytesFloat > pow(10, 9) {
                    fileSizeBytesFloat = round(Float(fileSizeBytesFloat/pow(10, 9)) * 10) / 10
                    fsbString = String(fileSizeBytesFloat) + "GB"
                } else if fileSizeBytesFloat > pow(10, 6) {
                    fileSizeBytesFloat = round(Float(fileSizeBytesFloat/pow(10, 6)) * 10) / 10
                    fsbString = String(fileSizeBytesFloat) + "MB"
                } else if fileSizeBytesFloat > pow(10, 3) {
                    fileSizeBytesFloat = round(Float(fileSizeBytesFloat/pow(10, 3)) * 10) / 10
                    fsbString = String(fileSizeBytesFloat) + "KB"
                }
                self.fileSizeBytesString = fsbString
            }
       }
    }
    var fileSizeBytesString: String?
    var sellerUrl: String?
    var contentAdvisoryRating: String?
    var averageUserRating: Double? {
        didSet {
            if let averageUserRating = self.averageUserRating {
                self.averageUserRatingString = String(round(averageUserRating * 10) / 10)
            }
        }
    }
    var averageUserRatingString: String?
    var trackViewUrl: String?
    var userRatingCount: Int? {
        didSet {
            if let ratingCount = self.userRatingCount {
                if ratingCount >= 10000 {
                    let userRatingCountFloat = round(Float(Float(ratingCount)/pow(10, 4)) * 10) / 10
                    self.userRatingCountString = String(userRatingCountFloat) + "만"
                } else if ratingCount >= 1000 {
                    let userRatingCountFloat = round(Float(Float(ratingCount)/pow(10, 3)) * 10) / 10
                    self.userRatingCountString = String(userRatingCountFloat) + "천"
                } else {
                    self.userRatingCountString = String(ratingCount)
                }
            }
        }
    }
    var userRatingCountString: String?
    var trackContentRating: String?
    var description: String?
    var genres: [String]?
    var version: String?
    var releaseNotes: String?
}
