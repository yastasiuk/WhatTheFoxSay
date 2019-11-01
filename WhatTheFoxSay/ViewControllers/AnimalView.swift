//
//  AnimalView.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 29.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import SwiftUI

struct AnimalView: View {
    @ObservedObject var imageLoader: ImageLoaderService
    @State var image:UIImage = UIImage()
    
    var animal: Animal
    
    init(animal: Animal) {
        print("[AnimalView] init()", animal)
        self.animal = animal
        imageLoader = ImageLoaderService(urlString: animal.imagesURI[0])
    }
    
    var body: some View {
            ScrollView {
                VStack {
                    Image(uiImage: image)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color.orange)

                    Text(animal.description)
                }.onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .navigationBarTitle(Text(animal.name), displayMode: .inline)
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

