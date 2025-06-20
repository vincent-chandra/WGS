//
//  MovieListCell.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import SwiftUI

struct MovieListCell: View {
    let title: String
    let urlString: String
    var body: some View {
        VStack {
            Text(title)
                .multilineTextAlignment(.center)
                .frame(maxHeight: .infinity, alignment: .bottom)
            AsyncImage(url: URL(string: urlString))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(20)
        }
    }
}
