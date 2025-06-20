//
//  ReviewCell.swift
//  TechnicalTestWGS
//
//  Created by Vincent on 20/06/25.
//

import SwiftUI

struct ReviewCell: View {
    
    let imageProfile: String
    let name: String
    let review: String
    let rate: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: URL(string: imageProfile)) { result in
                    result.image?.resizable()
                        .scaledToFill()
                }
                .frame(width: 80, height: 80)
                .cornerRadius(25)
                
                VStack(alignment: .leading) {
                    Text(name)
                        .font(Font.title3)
                        .bold()
                    Text(review)
                        .lineLimit(4)
                }
            }
            Text("\(rate)/10")
                .padding(.leading, 20)
        }
        .background(.gray)
        .frame(maxHeight: 200)
        .cornerRadius(20)
        .padding(20)
    }
}
