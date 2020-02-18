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
  
  var body: some View {
    VStack{
      HStack{
        Text("Photos of Damages").font(.headline).padding(.leading)
        Spacer()
        Button("Add Photo"){
          self.showingImagePicker = true
        }.padding(.trailing)
      }
      GridView(images: self.selectedImages)
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker(selectedImages: self.$selectedImages)
    }
  }
}

struct PhotosCmp_Previews: PreviewProvider {
    static var previews: some View {
      PhotosCmp(selectedImages: [UIImage]())
    }
}
