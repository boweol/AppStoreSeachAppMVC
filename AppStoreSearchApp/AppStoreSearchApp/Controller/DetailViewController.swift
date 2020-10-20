//
//  DetailViewController.swift
//  AppStoreSearchApp
//
//  Created by isens on 28/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

enum DetailViewInfoType: Int {
    case sellerName
    case fileSizeBytesString
    case genres
    case minimumOsVersion
    case languageCodesISO2A
    case contentAdvisoryRating
    case sellerNameCopyRight
    case sellerUrl
}

class DetailViewController: UIViewController {
    @IBOutlet weak var screenshotScrollView: UIScrollView!
    
    @IBOutlet weak var infoTableView: UITableView!
    
    @IBOutlet weak var artworkUrlImageView: UIImageView!
    @IBOutlet var averageUserRatingImageViews: [UIImageView]!
    
    @IBOutlet weak var newFunctionView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var developerView: UIView!
    @IBOutlet weak var reviewView: UIView!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackDetailLabel: UILabel!
    @IBOutlet weak var averageUserRatingLabel: UILabel!
    @IBOutlet weak var contentAdvisoryRatingLabel: UILabel!
    @IBOutlet weak var userRatingCountLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var releaseNotesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var reviewAverageUserRatingLabel: UILabel!
    @IBOutlet weak var reviewUserRatingCountLabel: UILabel!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var newFunctionMoreButton: UIButton!
    @IBOutlet weak var descriptionMoreButton: UIButton!
    
    @IBOutlet weak var newFunctionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var releaseNotesLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelTrailingConstraint: NSLayoutConstraint!
    
    let dateFormatter = DateFormatter() // 최신 릴리스 날짜 표시를 위한 포멧
    var iTunesSoftware: ITunesSoftware? // 데이터 모델
    var infoList: [[String: Any]] = [] // 정보 테이블 리스트
    var infoCellHeightList: [CGFloat] = [] // 정보 테이블 셀 높이 리스트
    
// MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register tableview
        self.infoTableView.register(UINib(nibName: "DetailInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailInfoTableViewCell")
        
        // 개발자 항목 선택 처리
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTappedDeveloperView))
        self.developerView.isUserInteractionEnabled = true
        self.developerView.addGestureRecognizer(tap)
        
        // set dateFormatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let iTunesSoftware = self.iTunesSoftware {
            // set setInfoList
            self.setInfoList(iTunesSoftware)
            
            // set infoCellHeightList
            for _ in infoList {
                self.infoCellHeightList.append(30.0)
            }
            
            // set UI
            self.setUI(iTunesSoftware)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set navigation settings
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
// MARK: event
    // 상단 네비게이션의 열기 버튼 누른 경우
    @objc func onTappedOpenButton(_ sender: Any) {
        self.gotoOpenAppView()
    }
    
    // 타이틀의 열기 버튼 누른 경우
    @IBAction func openButton(_ sender: Any) {
        self.gotoOpenAppView()
    }
    
    // 타이틀의 공유 버튼 누른 경우
    @IBAction func onTappeShare(_ sender: Any) {
        guard let iTunesSoftware = self.iTunesSoftware, let trackViewUrl = iTunesSoftware.trackViewUrl else {
            return
        }
        
        let items = [URL(string: trackViewUrl)!]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // 새로운 기능 더보기 누른 경우
    @IBAction func onTappedNewFunctionMore(_ sender: Any) {
        self.releaseNotesLabel.sizeToFit()
        self.newFunctionViewHeightConstraint.constant = self.releaseNotesLabel.frame.height + 90
        self.newFunctionMoreButton.isHidden = true
        self.releaseNotesLabelTrailingConstraint.constant = -50
    }
    
    // 설명 더보기 누른 경우
    @IBAction func onTappedDescriptionMore(_ sender: Any) {
        self.descriptionLabel.sizeToFit()
        self.descriptionViewHeightConstraint.constant = self.descriptionLabel.frame.height
        self.descriptionMoreButton.isHidden = true
        self.descriptionLabelTrailingConstraint.constant = -50
    }
    
    // 개발자 뷰 누른 경우
    @objc func onTappedDeveloperView(recognizer: UITapGestureRecognizer) {
        if let vc: UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "developerView") {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
// MARK: private
    // set UI
    private func setUI(_ iTunesSoftware: ITunesSoftware) {
        // set tableView footerview zero
        self.infoTableView.tableFooterView = UIView(frame: .zero)
        
        // set navigationItem
        self.setNavigationItem(iTunesSoftware)
        
        // 타이틀
        self.artworkUrlImageView.layer.cornerRadius = 15.0
        if let artworkUrlString: String = iTunesSoftware.artworkUrl512 {
            if let url = URL(string: artworkUrlString) {
                do {
                    let data = try Data(contentsOf: url)
                    self.artworkUrlImageView.image = UIImage(data: data)
                } catch {
                    print("artworkUrlImageView error: \(error.localizedDescription)")
                }
            }
        }
        
        self.openButton.layer.cornerRadius = 15.0
        
        if let trackName: String = iTunesSoftware.trackName {
            self.trackNameLabel.text = trackName
        }
        
        if let cellerName: String = iTunesSoftware.sellerName {
            self.trackDetailLabel.text = cellerName
        }
        
        if let averageUserRating: Double = iTunesSoftware.averageUserRating {
            for imageView in self.averageUserRatingImageViews {
                imageView.image = UIImage(systemName: "star")
            }
            for i in 0..<Int(round(averageUserRating)) {
               self.averageUserRatingImageViews[i].image = UIImage(systemName: "star.fill")
            }
        }
        
        if let averageUserRatingString: String = iTunesSoftware.averageUserRatingString {
            self.averageUserRatingLabel.text = averageUserRatingString
        }
        
        if let contentAdvisoryRating: String = iTunesSoftware.contentAdvisoryRating {
            self.contentAdvisoryRatingLabel.text = contentAdvisoryRating
        }
        
        if let userRatingCountString: String = iTunesSoftware.userRatingCountString {
            self.userRatingCountLabel.text = userRatingCountString + "개의 평가"
        }
        
        if let genres: [String] = iTunesSoftware.genres, genres.count > 0 {
            self.genresLabel.text = genres[0]
        }
        
        // 새로운 기능
        self.newFunctionView.layer.addBorder([.top], thick: 1.0, widthMargin: 40)
        
        if let version: String = iTunesSoftware.version {
            self.versionLabel.text = "버전 " + version
        }
        
        if let releaseDate: String = iTunesSoftware.currentVersionReleaseDate {
            self.setReleaseDateLabel(releaseDate)
        }
        
        if let releaseNotes: String = iTunesSoftware.releaseNotes {
            self.releaseNotesLabel.text = releaseNotes
        }
                        
        // 미리보기
        if let screenshotUrlStrings: [String] = iTunesSoftware.screenshotUrls {
            let subViews = self.screenshotScrollView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            for imageUrlString in screenshotUrlStrings {
                if let url = URL(string: imageUrlString) {
                    do {
                        let data = try Data(contentsOf: url)
                        self.addViewInScrollView(UIImage(data: data))
                    } catch {
                        print("screenshotScrollView error: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // 앱 설명
        self.descriptionView.layer.addBorder([.top], thick: 1.0, widthMargin: 40)
        if let description: String = iTunesSoftware.description {
            self.descriptionLabel.text = description
        }
        
        // 개발자
        if let sellerName: String = iTunesSoftware.sellerName {
            self.sellerNameLabel.text = sellerName
        }
        
        // 평가 및 리뷰
        self.reviewView.layer.addBorder([.bottom], thick: 1.0, widthMargin: 40)
        self.reviewAverageUserRatingLabel.text = self.averageUserRatingLabel.text
        if let userRatingCount: Int = iTunesSoftware.userRatingCount {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            self.reviewUserRatingCountLabel.text = (numberFormatter.string(from: NSNumber(value:userRatingCount)) ?? "") + "개의 평가"
        }
        
        self.infoTableView.reloadData()
    }
    
    // 앱 열기 화면으로 이동.. 원래는 설치된 앱이 열리면 됨
    private func gotoOpenAppView() {
        if let vc: UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "openedAppView") {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set navigationItem(가운데 이미지, 오른쪽 열기 버튼)
    private func setNavigationItem(_ iTunesSoftware: ITunesSoftware) {
        // 가운데 이미지
        if let artworkUrl60: String = iTunesSoftware.artworkUrl60 {
            if let url = URL(string: artworkUrl60) {
                do {
                    let data = try Data(contentsOf: url)
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    imageView.image = UIImage(data: data)
                    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    titleView.addSubview(imageView)
                    self.navigationItem.titleView = titleView
                } catch {
                    print("detailview navigationItem image error: \(error.localizedDescription)")
                }
            }
        }
        
        // 오른쪽 열기 버튼
        let openButton = UIButton()
        openButton.frame = CGRect(x:0, y:0, width:80, height:27)
        openButton.setTitle("열기", for: .normal)
        openButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        openButton.tintColor = UIColor.white
        openButton.backgroundColor = UIColor.systemBlue
        openButton.layer.cornerRadius = 15.0
        openButton.addTarget(self, action: #selector(onTappedOpenButton), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: openButton)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    // 배포 날짜 설정
    private func setReleaseDateLabel(_ releaseDateString: String) {
        let today = Date()
        let todayTimeInterval = today.timeIntervalSince1970
        if let releaseDate = dateFormatter.date(from: releaseDateString) {
            let releaseTimeInterval = releaseDate.timeIntervalSince1970
            let timeGapInterval = Int(todayTimeInterval - releaseTimeInterval)
            let hourSec = 60 * 60
            let daySec = 24 * 60 * 60
            if timeGapInterval > (365 * daySec) {
                let year = Int(timeGapInterval / (365 * daySec))
                self.releaseDateLabel.text = String(year) + "년 전"
            } else if timeGapInterval > (30 * daySec) {
                let month = Int(timeGapInterval / (30 * daySec))
                self.releaseDateLabel.text = String(month) + "개월 전"
            } else if timeGapInterval > (7 * daySec) {
               let weak = Int(timeGapInterval / (7 * daySec))
               self.releaseDateLabel.text = String(weak) + "주 전"
            } else if timeGapInterval > daySec {
                let day = Int(timeGapInterval / daySec)
                self.releaseDateLabel.text = String(day) + "일 전"
            } else if timeGapInterval > hourSec {
                let time = Int(timeGapInterval / hourSec)
                self.releaseDateLabel.text = String(time) + "시간 전"
            }
        }
    }
    
    // 미리보기 스크롤뷰에 이미지 뷰 추가
    private func addViewInScrollView(_ image: UIImage?) {
        if let img = image {
            let xPosition = self.screenshotScrollView.contentSize.width
            let view: UIImageView = UIImageView(frame: CGRect(x: xPosition, y: 0, width: 180, height: 300))
            view.image = img
            view.layer.cornerRadius = 15.0
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            self.screenshotScrollView.addSubview(view)
            self.screenshotScrollView.contentSize.width += 180 + 10
        }
    }
    
    // 정보 리스트
    private func setInfoList(_ iTunesSoftware: ITunesSoftware) {
        if let sellerName = iTunesSoftware.sellerName {
            self.infoList.append(["type": DetailViewInfoType.sellerName, "title": "제공자", "value": sellerName])
        }
        if let fileSizeBytesString = iTunesSoftware.fileSizeBytesString {
            self.infoList.append(["type": DetailViewInfoType.fileSizeBytesString, "title": "크기", "value": fileSizeBytesString])
        }
        if let genres = iTunesSoftware.genres, genres.count > 0 {
            self.infoList.append(["type": DetailViewInfoType.genres, "title": "카테고리", "value": genres[0]])
        }
        if let minimumOsVersion = iTunesSoftware.minimumOsVersion {
            self.infoList.append(["type": DetailViewInfoType.minimumOsVersion, "title": "호환성", "value": minimumOsVersion, "detail": minimumOsVersion])
        }
        if let languageCodesISO2A = iTunesSoftware.languageCodesISO2A, languageCodesISO2A.count > 0 {
            var languageCodesSrting = languageCodesISO2A[0]
            if languageCodesISO2A.count > 1 {
                languageCodesSrting += " 외 " + String(languageCodesISO2A.count - 1) + "개"

                var languageCodesDetailSring = ""
                if let languageCodesISO2AString = iTunesSoftware.languageCodesISO2AString {
                    languageCodesDetailSring = languageCodesISO2AString
                }
                self.infoList.append(["type": DetailViewInfoType.languageCodesISO2A, "title": "언어", "value": languageCodesSrting, "detail": languageCodesDetailSring])
            } else {
                self.infoList.append(["type": DetailViewInfoType.languageCodesISO2A, "title": "언어", "value": languageCodesSrting])
            }
        }
        if let contentAdvisoryRating = iTunesSoftware.contentAdvisoryRating {
            self.infoList.append(["type": DetailViewInfoType.contentAdvisoryRating, "title": "연령 등급", "value": contentAdvisoryRating, "detail": contentAdvisoryRating])
        }
        if let sellerName = iTunesSoftware.sellerName {
            self.infoList.append(["type": DetailViewInfoType.sellerNameCopyRight, "title": "저작권", "value": "© " + sellerName])
        }
        if let sellerUrl = iTunesSoftware.sellerUrl {
            self.infoList.append(["type": DetailViewInfoType.sellerUrl, "title": "개발자 웹 사이트", "value": sellerUrl])
        }
    }
        
// MARK: public
    // set 데이터 모델
    func setDetailInfoObj(_ detailInfo: ITunesSoftware) {
        self.iTunesSoftware = detailInfo
    }
}

// MARK: delegate UITableView
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 테이블 row 수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infoList.count
    }
    
    // 테이블 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.infoCellHeightList[indexPath.row]
    }
    
    // 테이블 셀 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DetailInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoTableViewCell") as! DetailInfoTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel.text = self.infoList[indexPath.row]["title"] as? String ?? ""
        cell.delegate = self
        
        // 셀 타입 지정
        let key = self.infoList[indexPath.row]["type"] as? DetailViewInfoType ?? DetailViewInfoType.sellerName
        if key == .sellerUrl {
            cell.setType(.image, index: indexPath.row)
        } else if key == .minimumOsVersion || key == .contentAdvisoryRating {
            cell.setType(.arrow, index: indexPath.row, isExpanded: self.infoCellHeightList[indexPath.row] > 30 ? true : false)
        } else {
            cell.setType(.str, index: indexPath.row)
        }
        
        // 셀 내용 적용
        let value: String = self.infoList[indexPath.row]["value"] as? String ?? ""
        cell.subTitleLabel.text = value
        if let detail: String = self.infoList[indexPath.row]["detail"] as? String {
            cell.detailLabel.text = detail
            cell.setType(.arrow, index: indexPath.row, isExpanded: self.infoCellHeightList[indexPath.row] > 30 ? true : false)
        }
        
        return cell
    }
    
    // 셀 누른 경우
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 개발자 웹 사이트 링크 이동
        if indexPath.row == DetailViewInfoType.sellerUrl.rawValue {
            if let iTunesSoftware = self.iTunesSoftware {
                if let sellerUrl = iTunesSoftware.sellerUrl {
                    if let url = URL(string: sellerUrl) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
        }
    }
}

// MARK: extension DetailInfoTableViewCell
extension DetailViewController: DetailInfoTableViewCellDelegate {
    
    // 높이 변경된 경우
    func changedHeight(_ index: Int) {
        self.infoCellHeightList[index] = 70
        self.infoTableView.reloadData()
    }
}
