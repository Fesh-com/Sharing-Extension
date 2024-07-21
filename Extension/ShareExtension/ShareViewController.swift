//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Marc Stibane on 2024-07-04.
//

import UIKit
import Social

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import os.log

class ShareViewController: UIViewController {
    let logger = Logger(subsystem: "com.fesh.containingdemo.ShareExtensionDemo", category: "ShareSheet")

    var returnArray: [NSExtensionItem] = []     // https://developer.apple.com/documentation/foundation/nsextensionitem
    let center = NotificationCenter.default
    var observer: NSObjectProtocol?
    //    let notificationName = NSNotification.Name("ShareExtension_close")

    func removeObserver() {
        if let observer = self.observer {
            self.observer = nil
            self.center.removeObserver(observer as Any, name: .closeExtension, object: nil)
        }
    }
    func cancel(error: Error) {
        self.logger.log("❗️❗️error=\(error)")
        removeObserver()
        self.extensionContext?.cancelRequest(withError: error)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure access to extensionItem and itemProvider
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem
            else { cancel(error: SharingError.inputItemError); return }
        guard let itemProvider = extensionItem.attachments?.first
            else { cancel(error: SharingError.inputItemAttachmentError); return }
        logger.log("❗️itemProvider=\(itemProvider)")

        // Check type identifier
        let textDataType = UTType.plainText.identifier
        let shareInputType = UTType.shareInput.identifier

        if itemProvider.hasItemConformingToTypeIdentifier(shareInputType) {
            itemProvider.loadItem(forTypeIdentifier: shareInputType , options: nil) { [weak self] (input, error) in
                guard error == nil else { self?.cancel(error: error!); return }

                if self != nil {
                    do {
                        let shareInput = try JSONDecoder().decode(ShareInput.self, from: input as! Data)
                        // if we get here, we're good and can show the View :D
                        let text = shareInput.inputStr2
                        DispatchQueue.main.async {
                            // host the SwiftU view
                            let extensionView = ShareExtensionView(extensionContext: self!.extensionContext,
                                                                               text: text)
                            let contentView = UIHostingController(rootView: extensionView)
                            self?.addChild(contentView)
                            self?.view.addSubview(contentView.view)

                            // set up constraints
                            contentView.view.translatesAutoresizingMaskIntoConstraints = false
                            contentView.view.topAnchor.constraint(equalTo: self!.view.topAnchor).isActive = true
                            contentView.view.bottomAnchor.constraint (equalTo: self!.view.bottomAnchor).isActive = true
                            contentView.view.leftAnchor.constraint(equalTo: self!.view.leftAnchor).isActive = true
                            contentView.view.rightAnchor.constraint (equalTo: self!.view.rightAnchor).isActive = true
                        }

                        self?.observer = self?.center.addObserver(forName: .closeExtension, object: nil, queue: nil) { _ in
                            DispatchQueue.main.async {
                                self?.done()
                            }
                        }
                        // done, extension is now showing the data
                        return

                    } catch let error {
                        self?.logger.log("\(error)")
                    }
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            itemProvider.loadItem(forTypeIdentifier: textDataType , options: nil) { [weak self] (providedText, error) in
                guard error == nil else { self?.cancel(error: error!); return }

                if let text = providedText as? String {
                    self?.logger.log("❗️providedText=\(text)")
                    if self != nil {
                        // if we get here, we're good and can show the View :D
                        DispatchQueue.main.async {
                            // host the SwiftU view
                            let extensionView = ShareExtensionView(extensionContext: self!.extensionContext,
                                                                               text: text)
                            let contentView = UIHostingController(rootView: extensionView)
                            self!.addChild(contentView)
                            self!.view.addSubview(contentView.view)

                            // set up constraints
                            contentView.view.translatesAutoresizingMaskIntoConstraints = false
                            contentView.view.topAnchor.constraint(equalTo: self!.view.topAnchor).isActive = true
                            contentView.view.bottomAnchor.constraint (equalTo: self!.view.bottomAnchor).isActive = true
                            contentView.view.leftAnchor.constraint(equalTo: self!.view.leftAnchor).isActive = true
                            contentView.view.rightAnchor.constraint (equalTo: self!.view.rightAnchor).isActive = true
                        }

                        self?.observer = self?.center.addObserver(forName: .closeExtension, object: nil, queue: nil) { _ in
                            DispatchQueue.main.async {
                                self?.done()
                            }
                        }
                    }
                } else {
                    let string = String(describing: providedText)
                    self?.logger.error("❗️❗️No String❗️ \(string)")
                    self?.cancel(error: SharingError.inputItemError)
                    return
                }
            }
        } else {
            logger.error("❗️❗️Neither ShareInput nor Text ❗️❗️")
            cancel(error: SharingError.inputItemError)
        }
    }

    func done() {
        logger.trace("❗️❗️closing❗️❗️")
        removeObserver()
        self.extensionContext?.completeRequest(returningItems: returnArray, completionHandler: nil)
        // https://developer.apple.com/documentation/foundation/nsextensioncontext/1411301-completerequest
        // https://developer.apple.com/documentation/foundation/nsextensioncontext/1412773-cancelrequest
        //   https://developer.apple.com/documentation/foundation/nsextensionitemsanderrorskey
    }
}

// the following -commented- code is from Apple's ActionExtension template:

//class ShareViewController: SLComposeServiceViewController {
//
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }
//
//}
