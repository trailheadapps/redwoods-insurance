//
//  GridView.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/15/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct GridView: View {
  var images: [UIImage]
  var body: some View {
    let chunks = self.images.chunked(into: 4)
    return GeometryReader { geo in
      List(chunks.indices, id: \.self) { idx in
        GridViewRow(images: chunks[idx], row: idx, geo: geo )
      }.frame(height: CGFloat(chunks.count) * (geo.size.width / 4) )
    }
  }
}

struct GridViewRow: View {
  var images: [UIImage]
  var row: Int
  var geo: GeometryProxy
  var body: some View {
    HStack {
      ForEach(0..<4) { col in
        GridViewCell(images: self.images, idx: col)
          .frame(width: self.geo.size.width / 4)
      }
    }
  }
}

struct GridViewCell: View {
  var images: [UIImage]
  var idx: Int

  var body: some View {
    if let image = self.images.get(at: self.idx) {
      return AnyView(Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .scaledToFit()
      )
    } else {
      return AnyView(EmptyView())
    }
  }
}

struct GridView_Previews: PreviewProvider {
  static var previews: some View {
    GridView(images: [UIImage]())
  }
}
