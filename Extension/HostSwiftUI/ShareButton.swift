//
//  ShareButton.swift
//  HostSwiftUI
//
//  Created by Marc Stibane on 2024-07-04.
//
import Foundation
import UIKit
import SwiftUI
import os.log
// MARK: -
class ActivityItemSource: NSObject, UIActivityItemSource {
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
struct ShareButton: View {
    var title: String
//    var shareItems: [InputItemSource]
    var shareItems: [UIActivityItemSource]

    let logger = Logger(subsystem: "com.fesh.Host", category: "ShareSheet")
    @State private var showShareSheet: Bool = false
    @State private var activityViewController: UIActivityViewController?

    var body: some View {
        Button(action: share) {
            Image(systemName: "square.and.arrow.up")
            Text(title)
        }
    }

    func share() {
        let completionHandler: UIActivityViewController.CompletionWithItemsHandler = { [self]
            (type: UIActivity.ActivityType?, completed: Bool, retItems: [Any]?, error:Error?) in
///            Upon the completion of an activity, or the dismissal of the activity view controller, the view controller’s completion block is executed.
///            You can use this block to execute any final code related to the service. The parameters of this block are as follows:
///            activityType
///              The type of the service that was selected by the user. For custom services, this is the value returned by the
///              activityType method of a UIActivity object. For system-defined activities, it is one of the strings listed
///              in "Built-in Activity Types” in UIActivity.
///            completed
///              true if the service was performed or false if it was not. This parameter is also set to false when the user
///              dismisses the view controller without selecting a service.
///            returnedItems
///              An array of NSExtensionItem objects containing any modified data. Use the items in this array to get any
///              changes made to the original data by an extension. If no items were modified, the value of this parameter is nil.
///            activityError
///              An error object if the activity failed to complete, or nil if the the activity completed normally.
            guard error == nil else {
                // TODO: pass error to host
                return
            }
            if completed {
                let aType = String("\(type)")
                logger.log("❗️type=\(aType, privacy: .public)")
                if let retItems {
                    for (index, item) in retItems.enumerated() {
                        if let extensionItem = item as? NSExtensionItem {
                            logger.log("❗️Found \(extensionItem) at position \(index)")
                            if let attachments = extensionItem.attachments {
                                if let itemProvider = attachments.first {
                                    logger.log("❗️Found \(itemProvider)")
                                    // TODO: Extract shareResult data

                                }
                            }
                        }
                    }
                }
            } else {
                logger.log("❗️Cancelled")
            }
        }

        activityViewController = UIActivityViewController(activityItems: shareItems,
                                                  applicationActivities: [])
        activityViewController!.completionWithItemsHandler = completionHandler
        activityViewController!.excludedActivityTypes = [
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

        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            windowScene.keyWindow?.rootViewController?.present(activityViewController!, animated: true, completion: nil)
        }
    }
}

