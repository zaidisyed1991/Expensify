//
//  LoadingView.swift
//  Expensify2021
//
//  Created by Syed on 27/11/2021.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView().scaleEffect(x: 2, y: 2).tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.2))
    }
}
