//
//  RecentSearchWords.swift
//  AppStoreSearchApp
//
//  Created by isens on 26/08/2020.
//  Copyright © 2020 isens. All rights reserved.
//
// 최근 검색어 로컬 데이터 저장소

import Foundation

class RecentSearchWords {
    static let shared = RecentSearchWords()  // singleton
    
    private var searchList: [String] = []
    private final let key: String = "RecentSearchWordList"
    
// MARK: private
    private init() {
        // set init searchList
        // 오래된 순으로 정렬되어 있음(최신 데이터가 앞쪽)
        self.searchList = getData()
    }
    
// MARK: public
    // 최근 검색어 추가
    func setData(_ searchedString: String) {
        self.searchList.insert(searchedString, at: 0)
        let defaults = UserDefaults.standard
        defaults.set(Array(self.searchList), forKey: self.key)
    }
    
    // 이전에 찾은 검색어 다시 찾을 경우 최근 검색어 리스트 갱신
    // 이전에 찾은 검색어는 리스트에서 삭제 후 가장 최근 검색어에 추가시킴
    func researchData(_ index: Int) {
        let word = self.searchList[index]
        self.searchList.remove(at: index)
        self.setData(word)
    }
    
    // 최근 검색어 리스트 가져오기
    func getData() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.stringArray(forKey: self.key) ?? [String]()
    }
}
