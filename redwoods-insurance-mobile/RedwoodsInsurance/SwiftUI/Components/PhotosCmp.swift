//
//  PhotosCmp.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/15/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct PhotosCmp: View {
  @State private var showingImagePicker = false
  @State var selectedImages: [UIImage]
  @EnvironmentObject var newClaim: NewClaimModel
  
  var body: some View {
    VStack {
      HStack {
        Text("Photos of Damages").font(.headline).padding(.leading)
        Spacer()
        Button("Add Photo") {
          self.showingImagePicker = true
        }.padding(.trailing)
      }
      GridView(images: self.newClaim.images)
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker(selectedImages: self.$newClaim.images)
    }
  }
}

struct PhotosCmp_Previews: PreviewProvider {
  static var previews: some View {
    PhotosCmp(selectedImages: [UIImage]())
  }
}
