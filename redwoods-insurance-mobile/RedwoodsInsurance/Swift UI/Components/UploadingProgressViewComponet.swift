//
//  UploadingProgressViewComponet.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/10/21.
//  Copyright © 2021 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct UploadingProgressViewComponet: View {
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color(UIColor.systemBackground))
        .opacity(0.5)
      RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: .continuous)
        .fill(Color(UIColor.systemBackground))
        .frame(width: 200, height: 200)
      ProgressView("Uploading")
        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
        .scaleEffect(1.5, anchor: .center)
    }
  }
}

struct UploadingProgressViewComponet_Previews: PreviewProvider {
  static var previews: some View {
    UploadingProgressViewComponet()
  }
}
