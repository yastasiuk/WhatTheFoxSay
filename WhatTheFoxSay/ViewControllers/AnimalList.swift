//
//  AnimalList.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 27.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import Combine

class AnimalListState: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var animalRows: Int = 0
    @Published var animalsLeft: Int = 0
}


struct AnimalList: View {
    @ObservedObject private var state = AnimalListState()
    private var elementsPerColumn: Int = 2
    
    
    init() {
        fetchAnimals()
    }
    
    func fetchAnimals() {
        print("[AnimalsList] fetchAnimals()")
        AnimalsService.getAnimals { (result) in
            switch(result) {
            case .success(let animals):
                self.updateAnimals(animals: animals)
            case .failure(let err):
                print("List Err:", err)
            }
        }
    }
    
    func updateAnimals(animals: Array<Animal>) {

        DispatchQueue.main.async {
            self.state.animals = animals
            self.state.animalRows = animals.count / self.elementsPerColumn
            self.state.animalsLeft = animals.count % self.elementsPerColumn
        }
    }
    
    func getAnimalIndex(rowIndex: Int, columnIndex: Int) -> Int {
        return rowIndex * self.elementsPerColumn + columnIndex
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        ForEach(0..<self.state.animalRows, id: \.self){ rowIndex in
                            HStack(alignment: .center) {
                                ForEach(0..<self.elementsPerColumn){ columnIndex in
                                    NavigationLink(
                                        destination: LazyView(AnimalView(animal: self.state.animals[self.getAnimalIndex(rowIndex: rowIndex, columnIndex: columnIndex)]))
                                    ) {
                                        AnimalAvatar(animal: self.state.animals[self.getAnimalIndex(rowIndex: rowIndex, columnIndex: columnIndex)])
                                            .frame(minWidth: geometry.size.width / CGFloat(self.elementsPerColumn), maxWidth: geometry.size.width / CGFloat(self.elementsPerColumn))
                                    }
                                }
                            }
                        }
                        HStack {
                            ForEach((self.state.animalRows * self.elementsPerColumn)..<self.state.animals.count, id: \.self){ columnIndex in
                                NavigationLink(
                                    destination: LazyView(AnimalView(animal: self.state.animals[columnIndex]))
                                ) {
                                    AnimalAvatar(animal: self.state.animals[columnIndex])
                                        .frame(minWidth: geometry.size.width / CGFloat(self.elementsPerColumn), maxWidth: geometry.size.width / CGFloat(self.elementsPerColumn))
                                }
                            }
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}


struct AnimalList_Previews: PreviewProvider {
    static var previews: some View {
        AnimalList()
    }
}

