//
//  APIKeyRequest.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation
import CryptoKit

struct ApiKeyRequest: APIRequest {
  
  let publicKey: String
  let nonce: String
  let clientID: String
  let keyPair: SecKey? // TODO: move
  
  init() {
    self.clientID = UUID().uuidString
    (self.keyPair, self.publicKey) = ApiKeyRequest.getPublicKey()
    self.nonce = ApiKeyRequest.getNonce()
  }
  var method: Method {
    return .GET
  }
  
  var path: String {
    return "/user-api-key/new"
  }
  var parameters: [String : String] {
    return [
      "auth_redirect": "discourse://auth_redirect",
      "application_name": "wmoverseas-iOS",
      "scopes": "notifications,session_info,write",
      "public_key": self.publicKey,
      "client_id": self.clientID,
      "nonce": self.nonce
    ]
  }
  
  static func getNonce() -> String {
    return Data(ChaChaPoly.Nonce()).base64EncodedString()
  }
  
  static func getPublicKey() -> (SecKey?, String) {
    
    let tag = "com.womenoverseas.userKey".data(using: .utf8)!
    var attributes: [CFString: Any] = [:]
    
    attributes[kSecAttrKeyType] = kSecAttrKeyTypeRSA
    attributes[kSecAttrKeySizeInBits] = 2048
    attributes[kSecPrivateKeyAttrs] = [kSecAttrIsPermanent: true, kSecAttrApplicationTag: tag]
    var error: Unmanaged<CFError>?
    if let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error), let publicKey = SecKeyCopyPublicKey(privateKey) {
      var error:Unmanaged<CFError>?
      if let cfdata = SecKeyCopyExternalRepresentation(publicKey, &error) {
        let publicKey_with_X509_header = try? ApiKeyRequest.prependX509KeyHeader(for: cfdata as Data)
        if let publicKey_with_X509_header = publicKey_with_X509_header {
          let b64Key = publicKey_with_X509_header.base64EncodedString()
          return (privateKey, "-----BEGIN PUBLIC KEY-----\n" + b64Key + "\n-----END PUBLIC KEY-----")
        }
      }
    }
    return (nil, "")
  }
  
  static func prependX509KeyHeader(for keyData: Data) throws -> Data {
    if try keyData.isAnHeaderlessKey() {
      let x509certificate: Data = keyData.prependx509Header()
      return x509certificate
    } else {
      throw AppError.x509CertificateFailed
    }
  }
}
