//
//  PhotoSelectionAndDisplayComponent.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct PhotoSelectionAndDisplayComponent: View {
  @State private var isShowingImagePicker = false
  @ObservedObject var newClaimViewModel: NewClaimViewModel

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]

  var body: some View {
    VStack {
      HStack {
        Text("Photos of Damage").font(.headline).padding(.leading)
        Spacer()
        Button("Add Photo") {
          self.isShowingImagePicker = true
        }.padding(.trailing)
      }
      ScrollView {
        LazyVGrid(columns: columns, spacing: 20) {
          ForEach(self.newClaimViewModel.selectedImages, id: \.self) { item in
            Image(uiImage: item)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .scaledToFit()
          }
        }
        .padding(.horizontal)
      }
    }.frame(height: 200.0)
    .sheet(isPresented: self.$isShowingImagePicker) {
      ImagePicker(selectedImages: self.$newClaimViewModel.selectedImages)
    }
  }
}

struct PhotoSelectionAndDisplayComponent_Previews: PreviewProvider {
  static var previews: some View {
    let newClaimViewModel = NewClaimViewModel()
    PhotoSelectionAndDisplayComponent(newClaimViewModel: newClaimViewModel)
  }
}
