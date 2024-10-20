//
//  LandingModel.swift
//  MVVM.Demo.SwiftUI
//
//  Created by Hailin Wang on 10/20/24.
//

import SwiftUI
struct Todo: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String?
}
