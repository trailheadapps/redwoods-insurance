//
//  ClaimUpload.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/1/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import Combine
import SalesforceSDKCore
import ContactsUI

class ClaimUpload: ObservableObject {
  
  private var accountIdRecord: RestClient.SalesforceRecord = RestClient.SalesforceRecord()
  private var accountIdCancellable: AnyCancellable?
  private var compositeCancellable: AnyCancellable?
  var contacts: [CNContact] = []
  private var accountId: String = ""
  
  let uploader = PassthroughSubject<ClaimUpload, Never>()
  
  func dontuse(){
    
    // Get master account
    let userId = UserAccountManager.shared.currentUserAccount!.accountIdentity.userId
    accountIdCancellable = RestClient.shared.records(fromQuery: "SELECT contact.accountId FROM User WHERE ID = '\(userId)' LIMIT 1")
      .print()
      .receive(on: RunLoop.main)
      .map{records in
        return records.first!
      }
      .sink { value in
        let contact = value["Contact"] as! RestClient.SalesforceRecord
        let accountId = contact["AccountId"] as! String
       
        // Create Contacts
        

        // Create Map Attachment
//        let compositeRequest = compositeRequestBuilder.buildCompositeRequest(RestClient.apiVersion)
//        print(compositeRequest.allSubRequests)
//        print(compositeRequest.allOrNone)
//        
//        RestClient.shared.send(compositeRequest: compositeRequest) { (result) in
//          switch result {
//            case .success(let response):
//              print(response.subResponses)
//            case .failure(let error):
//            print(error)
//          }
//        }
        
//        self.compositeCancellable = RestClient.shared.publisher(for: compositeRequest)
//          .print("Composite Request: ")
//          .tryMap{ try $0.asJson() as? RestClient.JSONKeyValuePairs ?? [:] }
//          .map{ $0["records"] as? RestClient.SalesforceRecords ?? [] }
//          .mapError { dump($0) }
//          .replaceError(with: [])
//          .eraseToAnyPublisher()
//          .receive(on: RunLoop.main)
//          .map{$0}
//          .sink{ response in
//            print(response)
//        }
      }

//      .assign(to: \ClaimUpload.AccountIdRecord, on: self)
    
    
    
    
    
    
    
    // Create Map Attachment
    // Create Photo Attachments
    // Create Audio Attachment
  }
  
}
