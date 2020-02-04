//
//  TestContactPickerTwo.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/28/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import ContactsUI
import SwiftUI
import Contacts
import Combine

protocol EmbeddedContactPickerViewControllerDelegate: class {
  func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController)
  func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contacts: [CNContact])
}

class EmbeddedContactPickerViewController: UIViewController, CNContactPickerDelegate {
  weak var delegate: EmbeddedContactPickerViewControllerDelegate?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.open(animated: animated)
  }
  
  private func open(animated: Bool) {
    let viewController = CNContactPickerViewController()
    viewController.delegate = self
    self.present(viewController, animated: false)
  }
  
  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    self.dismiss(animated: false) {
      self.delegate?.embeddedContactPickerViewControllerDidCancel(self)
    }
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
    self.dismiss(animated: false) {
      self.delegate?.embeddedContactPickerViewController(self, didSelect: contacts)
    }
  }
}

struct EmbeddedContactPicker: UIViewControllerRepresentable {
  
//  @Binding var selectedContacts: [CNContact]
  @EnvironmentObject var newClaim: NewClaimModel
  
  final class Coordinator: NSObject, EmbeddedContactPickerViewControllerDelegate {
    var parent: EmbeddedContactPicker
    
    init(_ parent: EmbeddedContactPicker) {
      self.parent = parent
    }
    
    func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contacts: [CNContact]) {
      viewController.dismiss(animated: true, completion: nil)
      self.parent.newClaim.contacts = contacts
      print(contacts)
    }
    
    func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController) {
      viewController.dismiss(animated: true, completion: nil)
      print("cancelled")
    }
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> EmbeddedContactPickerViewController {
    let result = EmbeddedContactPickerViewController()
    result.delegate = context.coordinator
    return result
  }
  
  func updateUIViewController(_ uiViewController: EmbeddedContactPickerViewController, context: Context) { }
  
}
