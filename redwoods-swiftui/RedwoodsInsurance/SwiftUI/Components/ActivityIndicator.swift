//
//  ActivityIndicator.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/12/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  @Binding var isAnimating: Bool
  let style: UIActivityIndicatorView.Style

  func makeUIView(context: Context) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: style)
  }

  func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
  }

}

struct ActivityIndicatorView<Content>: View where Content: View {
  @Binding var isShowing: Bool
  var content: () -> Content

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        self.content()
          .disabled(self.isShowing)
          .blur(radius: self.isShowing ? 2 : 0)
        VStack {
          Text("Submitting")
          ActivityIndicator(isAnimating: self.$isShowing, style: .large)
        }
        .frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
        .background(Color.secondary.colorInvert())
        .foregroundColor(Color.primary)
        .cornerRadius(20)
        .opacity(self.isShowing ? 1 : 0)
      }
    }
  }

}
