//
//  UITextViewWrapper.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/27/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import UIKit

struct UITextViewWrapper: UIViewRepresentable {

  @Binding var text: String
  @Binding var calculatedHeight: CGFloat
  @EnvironmentObject var newClaim: NewClaimModel

  var onCompletion: (() -> Void)?

  func makeUIView(context: Context) -> UITextView {
    let textField = UITextView()
    textField.delegate = context.coordinator
    
    textField.isEditable = true
    textField.backgroundColor = UIColor.clear
    textField.isSelectable = true
    textField.isUserInteractionEnabled = true
    textField.isScrollEnabled = true

    if onCompletion != nil {
      textField.returnKeyType = .done
    }

    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return textField
  }

  func makeCoordinator() -> TextFieldCoordinator {
    return TextFieldCoordinator(text: $text, height: $calculatedHeight, onDone: onCompletion)
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != self.text {
      uiView.text = self.text
    }
    
    if uiView.window != nil, uiView.window!.isFocused, !uiView.isFirstResponder {
      uiView.becomeFirstResponder()
    }
    UITextViewWrapper.recalcHeight(view: uiView, result: $calculatedHeight)
  }

  static func recalcHeight(view: UIView, result: Binding<CGFloat>) {
    let futureSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))

    if result.wrappedValue != futureSize.height {
      DispatchQueue.main.async {
        result.wrappedValue = futureSize.height
      }
    }

  }

  class TextFieldCoordinator: NSObject, UITextViewDelegate {
    var text: Binding<String>
    var calculatedHeight: Binding<CGFloat>
    var onComplete: (() -> Void)?

    init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil ) {
      self.text = text
      self.calculatedHeight = height
      self.onComplete = onDone
    }

    func textViewDidChange(_ textView: UITextView) {
      text.wrappedValue = textView.text
      UITextViewWrapper.recalcHeight(view: textView, result: calculatedHeight)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if let onDone = self.onComplete, text == "\n" {
        textView.resignFirstResponder()
        onDone()
        return false
      }
      return true
    }
  }

}

struct MultiLineTextField: View {
  private var placeholder: String
  private var onCommit: (() -> Void)?
  @EnvironmentObject var newClaim: NewClaimModel

  @Binding private var text: String
  private var internalText: Binding<String> {
    Binding<String>(get: {self.text}) { // swiftlint:disable:this multiple_closures_with_trailing_closure
      self.text = $0
      self.showingPlaceholder = $0.isEmpty
    }
  }

  @State private var dynamicHeight: CGFloat = 100
  @State private var showingPlaceholder = false

  init (_ placeholder: String = "", text: Binding<String>, onCommit: (() -> Void)? = nil) {
    self.placeholder = placeholder
    self.onCommit = onCommit
    self._text = text
    self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
  }

  var body: some View {
    UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onCompletion: onCommit)
      .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
      .overlay(placeholderView, alignment: .topLeading)
  }

  var placeholderView: some View {
    Group {
      if showingPlaceholder {
        Text(placeholder).foregroundColor(.gray)
          .padding(.leading, 4)
          .padding(.top, 8)
      }
    }
  }
}

struct UITextViewWrapper_Previews: PreviewProvider {
  static var textString = "Lorum Ipsum"
  static var textBinding = Binding<String>(get: {textString}, set: {textString = $0})

  static var previews: some View {
    MultiLineTextField("testing 123", text: textBinding, onCommit: {
      print("final text: \(textString)")
    })
  }
}
