//
//  ActivityViewController.swift
//  HostSwiftUI
//
//  Created by Marc Stibane on 2024-07-24.
//
import Foundation
import os.log
import LinkPresentation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ActivityViewController: UIViewControllerRepresentable {
    var configuration: UIActivityItemsConfigurationReading

    let logger = Logger(subsystem: "com.fesh.Host", category: "ActivityVC")
    let shareResultType = UTType.shareResult.identifier
    let resultItemSourceType = UTType.resultItemSource.identifier

    // called when HostApp uses ShareLink
    func loadTransferable(_ itemProvider: NSItemProvider) {
        let progress = itemProvider.loadTransferable(type: ShareResult.self) { [self] result in
            switch result {
                case .failure(let error):
                    self.logger.error("---->failure: \(error.localizedDescription)")
                case .success(let shareResult):
                    let resultStr2 = shareResult.outputStr2
                    self.logger.log("---->loadTransferable: \(resultStr2)")
                    // if we get here, we got the result back from the Sharing Extension
            }
        }
    }

    // called when HostApp uses UIActivityViewController
    func loadItemSource(_ itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: resultItemSourceType, options: nil) { [self] (result, error) in
            guard error == nil else { return }

            do {
                //                  let str = String(decoding: input as! Data, as: UTF8.self)
                let itemSource = try JSONDecoder().decode(ResultItemSource.self, from: result as! Data)
                // if we get here, we got the result back from the Sharing Extension
                let resultStr2 = itemSource.shareResult.outputStr2
                self.logger.log("---->loadItemSource: \(resultStr2)")

                return
            } catch DecodingError.dataCorrupted(let context) {
                print(context)
            } catch DecodingError.keyNotFound(let key, let context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.valueNotFound(let value, let context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch DecodingError.typeMismatch(let type, let context) {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let error {
                self.logger.error("\(error.localizedDescription)")
            }

            self.logger.log("wtf?")
        }
    }

    /// Upon the completion of an activity, or the dismissal of the activity view controller, this completion block is executed.
    /// You can use this block to execute any final code related to the service. The parameters of this block are as follows:
    /// activityType
    ///   The type of the service that was selected by the user. For custom services, this is the value returned by the
    ///   activityType method of a UIActivity object. For system-defined activities, it is one of the strings listed
    ///   in "Built-in Activity Types” in UIActivity.
    /// completed
    ///   true if the service was performed or false if it was not. This parameter is also set to false when the user
    ///   dismisses the view controller without selecting a service.
    /// returnedItems
    ///   An array of NSExtensionItem objects containing any modified data. Use the items in this array to get any
    ///   changes made to the original data by an extension. If no items were modified, the value of this parameter is nil.
    /// activityError
    ///   An error object if the activity failed to complete, or nil if the the activity completed normally.
    func myCompletionHandler(activityType: UIActivity.ActivityType?,
                                completed: Bool,
                            returnedItems: [Any]?,
                            activityError: Error?) -> Void {
        guard activityError == nil else {
            // TODO: pass error to host
            return
        }
        if completed {
//            let aType = String("\(activityType)")
//            logger.log("❗️type=\(aType, privacy: .public)")
            if let returnedItems {
                for (index, item) in returnedItems.enumerated() {
                    if let extensionItem = item as? NSExtensionItem {
//                        logger.log("❗️Found \(extensionItem) at position \(index)")
                        if let attachments = extensionItem.attachments {
                            if let itemProvider = attachments.first {
//                                logger.log("❗️Found \(itemProvider)")
                                if itemProvider.hasItemConformingToTypeIdentifier(shareResultType) {
                                    loadTransferable(itemProvider)
                                } else if itemProvider.hasItemConformingToTypeIdentifier(resultItemSourceType) {
                                    loadItemSource(itemProvider)
                                } else {
                                    logger.error("❗️❗️Neither ShareResult nor resultItemSource ❗️❗️")
                                }
                            }
                        }
                    }
                }
            } else {
                logger.log("❗️nothing returned")
            }
        } else {
            logger.log("❗️Cancelled")
        }
    }
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItemsConfiguration: configuration)
        activityVC.completionWithItemsHandler = myCompletionHandler
        activityVC.excludedActivityTypes = [
            .addToHomeScreen,           // needs iOS 16.4
            .addToReadingList,
            .airDrop,
            .assignToContact,
            .copyToPasteboard,
            .collaborationCopyLink,
            .collaborationInviteWithLink,
            .mail,
            .markupAsPDF,
            .message,
            .openInIBooks,
            .print,
            .saveToCameraRoll,
            .sharePlay,
            .postToFacebook,
            .postToFlickr,
//            .postToInstagram,     doesn't exist
            .postToTwitter,
            .postToVimeo,
            .postToWeibo,
            .postToTencentWeibo
        ]
        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
