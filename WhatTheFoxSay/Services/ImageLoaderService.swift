//
//  ImageLoaderService.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 29.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//


import Combine
import Foundation

class ImageLoaderService: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString:String) {
        print("[ImageLoaderService] init:", urlString)
        guard let url = URL(string: urlString) else { return }
        print("url", url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
