//
//  LazyView.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 30.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import Foundation
import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
