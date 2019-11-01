//
//  AnimalAvatar.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 29.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import Combine

// https://dev.to/gualtierofr/remote-images-in-swiftui-49jp
struct AnimalAvatar: View {
    @ObservedObject var imageLoader: ImageLoaderService
    @State var image:UIImage = UIImage()

    var animal: Animal
    
    init(animal: Animal) {
        self.animal = animal
        imageLoader = ImageLoaderService(urlString: animal.avatarURI.absoluteString!)
    }

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(Color.orange)
                .clipShape(Circle())
                .frame(maxHeight: 180.0)

            Text(animal.name)
                .font(.system(size: 24))
                .bold()
        }.onReceive(imageLoader.didChange) { data in
            self.image = UIImage(data: data) ?? UIImage()
        }
        .frame(height: 190)
    }
}
