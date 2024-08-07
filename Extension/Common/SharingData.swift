//
//  SharingData.swift
//  Common
//
//  Created by Marc Stibane on 2024-07-04.
//
import Foundation
import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers

enum SharingError: Error {
    case userCanceled
    case inputItemError
    case inputItemAttachmentError
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
class InputItemSource: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    let shareInput: ShareInput
    let previewTitle: String
    let previewImage: ImageWrapper

    init(shareInput: ShareInput, previewTitle: String, previewImage: UIImage) {
        self.shareInput = shareInput
        self.previewTitle = previewTitle
        self.previewImage = ImageWrapper(image: previewImage)
        super.init()
    }

    static var writableTypeIdentifiersForItemProvider: [String] {
        [// UTType.data.identifier,
         // UTType.shareInput.identifier,
            UTType.inputItemSource.identifier]
    }

    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let data = try? JSONEncoder().encode(self)
        completionHandler(data, nil)
        return nil
    }

    static var readableTypeIdentifiersForItemProvider: [String] {
        [// UTType.data.identifier,
         // UTType.shareInput.identifier,
            UTType.inputItemSource.identifier]
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let customItem = try JSONDecoder().decode(self, from: data)
        return customItem
    }
}

extension InputItemSource: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .inputItemSource)
//        ProxyRepresentation(exporting: \.outputStr)
    }
}

//extension InputItemSource: UIActivityItemSource {
//    func activityViewController(_ activityViewController: UIActivityViewController,
//              thumbnailImageForActivityType activityType: UIActivity.ActivityType?,
//                                      suggestedSize size: CGSize
//    ) -> UIImage? {
//        previewImage.image
//    }
//
//    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        previewTitle
//    }
//
//    func activityViewController(_ activityViewController: UIActivityViewController,
//          dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
////      UTType.shareInput.identifier
//        UTType.inputItemSource.identifier
//    }
//
//    func activityViewController(_ activityViewController: UIActivityViewController,
//                        itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        previewImage.image
//    }
//
//    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//        let metaData = LPLinkMetadata()
//        metaData.title = previewTitle
//        metaData.imageProvider = NSItemProvider(object: previewImage.image)
//        return metaData
//    }
//}

// MARK: -
struct ShareResult: Codable {
    var outputStr1: String
    var outputStr2: String
    // ... more result data
}

extension ShareResult: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .shareResult)
//        ProxyRepresentation(exporting: \.outputStr)
    }
}
// MARK: -
class ResultItemSource: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    let shareResult: ShareResult

    init(shareResult: ShareResult) {
        self.shareResult = shareResult
        super.init()
    }

    static var writableTypeIdentifiersForItemProvider: [String] {
        [// UTType.data.identifier,
         // UTType.shareResult.identifier,
            UTType.resultItemSource.identifier]
    }

    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }

    static var readableTypeIdentifiersForItemProvider: [String] {
        let types = [// UTType.data.identifier,
                     // UTType.shareResult.identifier,
                        UTType.resultItemSource.identifier]
        return types
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let customItem = try JSONDecoder().decode(self, from: data)
        return customItem
    }
}

extension ResultItemSource: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .resultItemSource)
//        ProxyRepresentation(exporting: \.outputStr)
    }
}


// MARK: - ImageWrapper

public struct ImageWrapper: Codable {
    public enum CodingKeys: String, CodingKey {
        case image
        case scale
    }

    public let image: UIImage

    public init(image: UIImage) {
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scale = try container.decode(CGFloat.self, forKey: .scale)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        if let image = UIImage(data: data, scale:scale) {
            self.image = image
        } else {
            self.image = UIImage()  // empty image
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let imageData: Data = image.pngData() {
            try container.encode(imageData, forKey: .image)
            try container.encode(image.scale, forKey: .scale)
        } else {
            // Encoding error
        }
    }
}
