//
//  SearchMainViewController.swift
//  AppStoreSearchApp
//
//  Created by isens on 26/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

class SearchMainViewController: UIViewController {
    @IBOutlet weak var recentTableView: UITableView! // 최근 검색어 테이블
    @IBOutlet weak var searchedTableView: UITableView! // 검색된 단어 테이블
    @IBOutlet weak var searchResultTableView: UITableView! // 검색 결과 테이블
    @IBOutlet weak var searchedView: UIView! // 검색된 단어 뷰
    @IBOutlet weak var searchResultView: UIView! // 검색 결과 뷰
    
    private var recentSearchWordList: [String] = [String]() // 최근 검색어 리스트. 오래된 순으로 정렬
    private var searchedWordList: [String] = [String]() // 검색된 단어 리스트
    private var searchResultList: [ITunesSoftware] = [ITunesSoftware]() // 검색 결과 리스트
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView() // 프로그레스바
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "App Store"
        return searchController
    }()
    
// MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register tableview
        self.recentTableView.register(UINib(nibName: "RecentSearchWordTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentSearchWordTableViewCell")
        self.searchedTableView.register(UINib(nibName: "SearchedTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchedTableViewCell")
        self.searchResultTableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableTableCell")
        
        // set searchContoller delegate
        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        
        // set navigation settings
        self.setNavigationSettings()
        
        // set recentSearchWordList
        self.recentSearchWordList = RecentSearchWords.shared.getData()
        
        // set UI
        self.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set navigation settings
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
    }
    
// MARK: private
    private func setNavigationSettings() {
        self.navigationItem.title = "검색"
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setUI() {        
        // view hidden
        self.searchedView.isHidden = true
        self.searchResultView.isHidden = true
        
        // set activityIndicator
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.center = view.center
        self.activityIndicator.startAnimating()
        view.addSubview(self.activityIndicator)
        self.hideActivityIndicator()
        
        // set tableView footerview zero
        self.recentTableView.tableFooterView = UIView(frame: .zero)
        self.searchedTableView.tableFooterView = UIView(frame: .zero)
        self.searchResultTableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    // 최신 검색어 리스트에 추가
    // 이미 있는 단어는 가장 최근 위치로 이동
    private func insertRecentSearchWordList(_ searchWord: String) {
        var isConflictIndex: Int = -1
        for (index, word) in recentSearchWordList.enumerated() {
            if word == searchWord {
                isConflictIndex = index
                break
            }
        }
        
        if isConflictIndex >= 0 {
            RecentSearchWords.shared.researchData(isConflictIndex)
            self.recentSearchWordList.remove(at: isConflictIndex)
        } else {
            RecentSearchWords.shared.setData(searchWord)
        }
        self.recentSearchWordList.insert(searchWord, at: 0)
        self.recentTableView.reloadData()
    }
    
    // 검색 시작
    private func search(_ searchWord: String) {
        self.showActivityIndicator()
        self.searchedView.isHidden = true
        self.searchResultView.isHidden = false
        
        self.insertRecentSearchWordList(searchWord)
        
        self.searchResultList = []
        self.searchResultTableView.reloadData() // 빈 리스트 표시(초기)
        ITunesService.shared.search(searchWord, onComplete: { (resultArray) in
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                if let resArray = resultArray {
                    self.searchResultList = resArray
                    self.searchResultTableView.reloadData()  // 검색된 리스트 표시
                } else { // 실패한 경우 검색 결과 뷰 보여줌
                    self.searchedView.isHidden = false
                    self.searchResultView.isHidden = true
                }
            }
        })
    }
}

// MARK: extension UISearchController, UISearchBar
extension SearchMainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    // 검색어 필드의 검색어가 업데이트 된 경우
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchKeyword = searchController.searchBar.text else {
            self.endEdit()
            return
        }
        if searchKeyword.count > 0 { // 입력된 값이 있는 경우
            self.startEdit()
            self.filterContentForSearchKeyWord(searchKeyword)
        } else { // 입력된 값이 없는 경우
            ITunesService.shared.cancel()
            self.endEdit()
        }
    }
    
    // 검색어 필드 오른쪽의 취소 버튼 누른 경우
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.endEdit()
        if self.activityIndicator.isHidden == false {
            ITunesService.shared.cancel()
            self.hideActivityIndicator()
        }
    }
    
    // 키보드에서 검색 버튼 누른 경우
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchKeyword = searchController.searchBar.text else {
            return
        }
        if searchKeyword.count > 0 {
            self.search(searchKeyword)
        }
    }
    
    // 입력 시작 화면
    private func startEdit() {
        if self.searchedView.isHidden == true {
            self.searchedView.isHidden = false
        }
        if self.searchResultView.isHidden == false {
            self.searchResultView.isHidden = true
        }
    }
    
    // 입력 종료 화면
    private func endEdit(isAnimationDown: Bool = true) {
        self.searchedWordList = []
        if self.searchedView.isHidden == false {
            self.searchedView.isHidden = true
        }
        if self.searchResultView.isHidden == false {
            self.searchResultView.isHidden = true
        }
    }
    
    // 최근 검색어 리스트에서 필터링
    private func filterContentForSearchKeyWord(_ searchKeyword: String) {
        self.searchedWordList = self.recentSearchWordList.filter { (word: String) -> Bool in
            word.contains(searchKeyword)
        }
        self.searchedTableView.reloadData()
    }
}

// MARK: extension UITableView
extension SearchMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 테이블 row 수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.recentTableView {
            return recentSearchWordList.count
        } else if tableView == self.searchedTableView {
            return searchedWordList.count
        } else {
            return searchResultList.count
        }
    }
    
    // 테이블 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == searchResultTableView {
            return 280
        } else {
            return 40
        }
    }
    
    // 테이블 셀 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.recentTableView {
            let cell: RecentSearchWordTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchWordTableViewCell") as! RecentSearchWordTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = recentSearchWordList[indexPath.row]
            return cell
        } else if tableView == self.searchedTableView {
            let cell: SearchedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchedTableViewCell") as! SearchedTableViewCell
            cell.selectionStyle = .none
            cell.titleLabel.text = self.searchedWordList[indexPath.row]
            return cell
        } else {
            let cell: SearchResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableTableCell") as! SearchResultTableViewCell
            cell.selectionStyle = .none
            let searchResultItem: ITunesSoftware = searchResultList[indexPath.row]
            if let trackName: String = searchResultItem.trackName {
                cell.trackNameLabel.text = trackName
            }
            if let genres: [String] = searchResultItem.genres, genres.count > 0 {
                cell.genresLabel.text = genres[0]
            }
            if let averageUserRating: Double = searchResultItem.averageUserRating {
                cell.setAverageUserRating(averageUserRating)
            }
            if let userRatingCountString: String = searchResultItem.userRatingCountString {
                cell.userRatingCountLabel.text = userRatingCountString
            }
            if let artworkUrl: String = searchResultItem.artworkUrl100 {
                cell.setArtworkUrlImage(artworkUrl)
            }
            if let screenshotUrls: [String] = searchResultItem.screenshotUrls {
                cell.setScreenshotUrlImages(screenshotUrls)
            }
            return cell
        }
    }
    
    // 셀 누른 경우
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentTableView {
            self.searchController.isActive = true // 검색어 필드 상단으로 이동
            self.searchController.searchBar.endEditing(true) // 키보드 사라지도록
            let searchWord = self.recentSearchWordList[indexPath.row]
            self.searchController.searchBar.text = searchWord // 검색어 필드에 검색어 설정
            self.search(searchWord) // 검색 시작
        } else if tableView == searchedTableView {
            self.searchController.searchBar.endEditing(true)  // 키보드 사라지도록
            let searchWord = self.searchedWordList[indexPath.row]
            self.searchController.searchBar.text = searchWord // 검색어 필드에 검색어 설정
            self.search(searchWord) // 검색 시작
        } else {
            // 뷰 이동
            if let vc: DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailViewController {
                vc.setDetailInfoObj(self.searchResultList[indexPath.row])
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
