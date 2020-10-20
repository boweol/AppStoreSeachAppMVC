//
//  ITunesService.swift
//  AppStoreSearchApp
//
//  Created by isens on 28/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//
//  iTunes Store Web Service Search API

import Foundation

enum ITunesServiceError {
    case url
    case session
    case data
    case jsonParsing
}

class ITunesService {
    static let shared = ITunesService() // singleton
    
    final let searchUrl: String = "https://itunes.apple.com/search?media=software&"
    private var searchContryCodeUrl: String = "country=kr&"
    private var sessionDataTask: URLSessionDataTask?

// MARK: private
    private init() {
        // get contry code
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            self.searchContryCodeUrl = "country=" + countryCode + "&"
        }
    }
    
    // ITunesSoftware 객체로 파싱
    private func setITunesSoftware(_ itemList: [Any]) -> [ITunesSoftware] {
        var iSoftwareArray: [ITunesSoftware] = []
        for item in itemList {
            let iSoftware: ITunesSoftware = ITunesSoftware()
            if let dic: [String: Any] = item as? [String: Any] {
                if let screenshotUrls: [String] = dic["screenshotUrls"] as? [String] {
                    iSoftware.screenshotUrls = screenshotUrls
                }
                if let artworkUrl60: String = dic["artworkUrl60"] as? String {
                    iSoftware.artworkUrl60 = artworkUrl60
                }
                if let artworkUrl100: String = dic["artworkUrl100"] as? String {
                    iSoftware.artworkUrl100 = artworkUrl100
                }
                if let artworkUrl512: String = dic["artworkUrl512"] as? String {
                    iSoftware.artworkUrl512 = artworkUrl512
                }
                if let artistViewUrl: String = dic["artistViewUrl"] as? String {
                    iSoftware.artistViewUrl = artistViewUrl
                }
                if let minimumOsVersion: String = dic["minimumOsVersion"] as? String {
                    iSoftware.minimumOsVersion = minimumOsVersion
                }
                if let trackName: String = dic["trackName"] as? String {
                    iSoftware.trackName = trackName
                }
                if let currentVersionReleaseDate: String = dic["currentVersionReleaseDate"] as? String {
                    iSoftware.currentVersionReleaseDate = currentVersionReleaseDate
                }
                if let sellerName: String = dic["sellerName"] as? String {
                    iSoftware.sellerName = sellerName
                }
                if let trackCensoredName: String = dic["trackCensoredName"] as? String {
                    iSoftware.trackCensoredName = trackCensoredName
                }
                if let languageCodesISO2A: [String] = dic["languageCodesISO2A"] as? [String] {
                    iSoftware.languageCodesISO2A = languageCodesISO2A
                }
                if let fileSizeBytes: String = dic["fileSizeBytes"] as? String {
                    iSoftware.fileSizeBytes = fileSizeBytes
                }
                if let sellerUrl: String = dic["sellerUrl"] as? String {
                    iSoftware.sellerUrl = sellerUrl
                }
                if let contentAdvisoryRating: String = dic["contentAdvisoryRating"] as? String {
                    iSoftware.contentAdvisoryRating = contentAdvisoryRating
                }
                if let averageUserRating: Double = dic["averageUserRating"] as? Double {
                    iSoftware.averageUserRating = averageUserRating
                }
                if let trackViewUrl: String = dic["trackViewUrl"] as? String {
                    iSoftware.trackViewUrl = trackViewUrl
                }
                if let userRatingCount: Int = dic["userRatingCount"] as? Int {
                    iSoftware.userRatingCount = userRatingCount
                }
                if let trackContentRating: String = dic["trackContentRating"] as? String {
                    iSoftware.trackContentRating = trackContentRating
                }
                if let description: String = dic["description"] as? String {
                    iSoftware.description = description
                }
                if let genres: [String] = dic["genres"] as? [String] {
                    iSoftware.genres = genres
                }
                if let version: String = dic["version"] as? String {
                    iSoftware.version = version
                }
                if let releaseNotes: String = dic["releaseNotes"] as? String {
                    iSoftware.releaseNotes = releaseNotes
                }
            }
            iSoftwareArray.append(iSoftware)
        }
        return iSoftwareArray
    }
    
// MARK: public
    // API 요청 함수로 들어가기 전 재귀함수 처리 함수
    // word: 찾을 단어, onComplete: 완료 클로저
    // 재귀함수 처리 이유 => 요청시 간헐적으로 Resource not found 나타나는 에러 발생
    //               => 해당 에러 발생 시 10번까지 재요청
    func search(_ word: String, onComplete: @escaping ([ITunesSoftware]?) -> Void) {
        // 재귀 처리 카운트
        var resourceErrorCount: Int = 0
        
        // 재귀 함수
        func tryRequestAPI(_ word: String, onComplete: @escaping ([ITunesSoftware]?) -> Void) {
            self.requestAPI(word, onComplete: { (result, error) in
                if let er = error, er == .jsonParsing, resourceErrorCount < 10 {
                    resourceErrorCount += 1
                    print("retry: \(resourceErrorCount)")
                    tryRequestAPI(word, onComplete: onComplete)
                } else {
                    onComplete(result)
                }
            })
        }
        tryRequestAPI(word, onComplete: onComplete)
    }
    
    // API 요청 취소
    func cancel() {
        self.sessionDataTask?.resume()
    }
    
    // API 요청
    private func requestAPI(_ word: String, onComplete: @escaping ([ITunesSoftware]?, ITunesServiceError?) -> Void) {
        // set url
        // 한글 포함인 경우를 위한 인코딩 처리
        let urlString: String = searchUrl + searchContryCodeUrl + "term=" + word
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: encodedString) else {
            onComplete(nil, .url)
            return
        }
        
        // post 요청
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        let session = URLSession.shared
        self.sessionDataTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in

            // error response
            guard error == nil && data != nil else {
                if let err = error {
                    print(err.localizedDescription)
                }
                onComplete(nil, .session)
                return
            }
            
            // get data
            if let _data = data {
                do {
                    // json 파싱
                    if let jsonResult = try JSONSerialization.jsonObject(with: _data, options: []) as? [String : Any] {
                        if let results: [Any] = jsonResult["results"] as? [Any] {
                            print("success")
                            onComplete(self.setITunesSoftware(results), nil)
                        } else {
                            onComplete(nil, .jsonParsing)
                        }
                    } else {
                        onComplete(nil, .jsonParsing)
                    }
                } catch let error as NSError {
                    print("error: " + error.localizedDescription)
                    onComplete(nil, .jsonParsing)
                }
            } else {
                onComplete(nil, .data)
            }
        })
        self.sessionDataTask?.resume()
    }
}
