//
//  RestClientExtentions.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import Combine

extension RestClient {
  static let apiVersion = "v47.0"

  typealias JSONKeyValuePairs = [String: Any]
  typealias SalesforceRecord = [String: Any]
  typealias SalesforceRecords = [SalesforceRecord]

  func records(fromQuery query: String) -> AnyPublisher<SalesforceRecords, Never> {
    let queryRequest = RestClient.shared.request(forQuery: query, apiVersion: RestClient.apiVersion)
    return self.publisher(for: queryRequest)
      .tryMap { try $0.asJson() as? JSONKeyValuePairs ?? [:] }
      .map { $0["records"] as? SalesforceRecords ?? [] }
      .mapError { dump($0) }
      .replaceError(with: [])
      .eraseToAnyPublisher()
  }

  func records<Record>(fromQuery query: String,
                       returningModel model: @escaping (SalesforceRecord) throws -> Record) -> AnyPublisher<[Record], Never> {
    let queryRequest = RestClient.shared.request(forQuery: query, apiVersion: RestClient.apiVersion)
    return self.publisher(for: queryRequest)
      .tryMap { try $0.asJson() as? JSONKeyValuePairs ?? [:] }
      .map { $0["records"] as? SalesforceRecords ?? [] }
      .tryMap { try $0.map { try model($0)}}
      .mapError { dump($0) }
      .replaceError(with: [])
      .eraseToAnyPublisher()
  }

  func fetchData(fromLayout named: String, for objectId: String) -> AnyPublisher<SalesforceRecords, Never> {
    let params: [String:Any] = ["layoutTypes": named]
    let uiApiRequest = RestRequest(method: .GET, path: "/\(RestClient.apiVersion)/ui-api/record-ui/\(objectId)", queryParams: params)

    return self.publisher(for: uiApiRequest)
      .tryMap { try $0.asJson() as! JSONKeyValuePairs }
      .map { $0["records"] as! [String:Any]}
      .map { $0[objectId] as! [String:Any]}
      .map { $0["fields"] as! [String:Any]}
      .map {
        return $0.map { (key, value) -> [String:Any] in
          if let fieldDetails = value as? [String: Any] {
            if let finalValue = fieldDetails["displayValue"] as? String {
              return [key:finalValue]
            } else if let finalValue = fieldDetails["value"] as? String {
              return[key:finalValue]
            } else {
              return [key: ""]
            }
          } else {
            return [:]
          }
        }
      }
      .mapError { dump($0) }
      .replaceError(with: SalesforceRecords() )
      .eraseToAnyPublisher()
  }

  /// Returns a request that adds an image attachment to a given case.
  ///
  /// - Parameters:
  ///   - image: The image to be attached to the case.
  ///   - caseID: The ID of the case to which the attachment is to be added.
  /// - Returns: The new request.
  func requestForCreatingImageAttachment(
    from image: UIImage,
    relatingToCaseID caseID: String,
    fileName: String? = nil) -> RestRequest {
    let imageData = image.resizedByHalf().pngData()!
    let uploadFileName = fileName ?? UUID().uuidString + ".png"
    return self.requestForCreatingAttachment(from: imageData, withFileName: uploadFileName, relatingToCaseID: caseID)
  }

  /// Returns a request that adds an audio attachment to a given case.
  ///
  /// - Parameters:
  ///   - m4aAudioData: The audio data, in M4A format, to be attached to the case.
  ///   - caseID: The ID of the case to which the attachment is to be added.
  /// - Returns: The new request.
  func requestForCreatingAudioAttachment(from m4aAudioData: Data, relatingToCaseID caseID: String) -> RestRequest {
    let fileName = UUID().uuidString + ".m4a"
    return self.requestForCreatingAttachment(from: m4aAudioData, withFileName: fileName, relatingToCaseID: caseID)
  }
  
  /// Returns a request that adds an attachment to a given case.
  ///
  /// - Parameters:
  ///   - data: The data for the attachment.
  ///   - fileName: The name to give the attachment (typically including
  ///     a file extension).
  ///   - caseID: The ID of the case to which the attachment is to be added.
  /// - Returns: The new request.
  private func requestForCreatingAttachment(
    from data: Data,
    withFileName fileName: String,
    relatingToCaseID caseID: String) -> RestRequest {
    let record = ["VersionData": data.base64EncodedString(options: .lineLength64Characters),
                  "Title": fileName,
                  "PathOnClient": fileName,
                  "FirstPublishLocationId": caseID,
                  "NetworkId": UserAccountManager.shared.currentUserAccount?.credentials.communityId ?? ""
    ]
    return self.requestForCreate(withObjectType: "ContentVersion", fields: record, apiVersion: RestClient.apiVersion)
  }
}
