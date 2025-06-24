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
                .frame(alignment: .bottom)
            AsyncImage(url: URL(string: urlString)) { result in
                if result.error != nil {
                    Image.init("MoviePlaceholder")
                        .resizable()
                        .scaledToFit()
                }
                result.image?.resizable()
                    .scaledToFit()
            }
            .cornerRadius(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
