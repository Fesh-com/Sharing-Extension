//
//  SharingData.swift
//  Common
//
//  Created by Marc Stibane on 2024-07-04.
//
import Foundation
import SwiftUI

enum SharingError: Error {
    case userCanceled
    case inputItemError
    case inputItemAttachmentError
}

// MARK: -
class ItemSource: NSObject, UIActivityItemSource {
    let dataToShare: Any

    init(dataToShare: Any) {
        self.dataToShare = dataToShare
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return dataToShare
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                        itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if let activityType, activityType == .copyToPasteboard {
            return "copyToPasteboard"
        } else {
            return dataToShare
        }
    }
}
// MARK: -
struct ShareInput: Codable {
    var inputStr1: String
    var inputStr2: String
    var inputStr3: String
    // ... more input data
}

extension ShareInput: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .shareInput)
//        ProxyRepresentation(exporting: \.inputStr)
    }
}

// MARK: -
struct ShareResult: Codable {
    var outputStr: String
    // ... more result data
}

extension ShareResult: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .shareResult)
//        ProxyRepresentation(exporting: \.outputStr)
    }
}
