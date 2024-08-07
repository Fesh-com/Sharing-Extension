//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Marc Stibane on 2024-07-04.
//

import os.log
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    let logger = Logger(subsystem: "com.fesh.containingdemo.ShareExtension", category: "ShareSheet")

    // Check type identifier
    let textType = UTType.text.identifier
    let plainTextType = UTType.plainText.identifier
    let dataType = UTType.data.identifier
    let shareInputType = UTType.shareInput.identifier
    let inputItemSourceType = UTType.inputItemSource.identifier

    @State var returnArray: [NSExtensionItem] = []     // https://developer.apple.com/documentation/foundation/nsextensionitem

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
        self.logger.log("❗️❗️error=\(error.localizedDescription)")
        removeObserver()
        self.extensionContext?.cancelRequest(withError: error)
    }

    @MainActor
    func addShareExtensionView(_ shareInput: ShareInput) {
        let text = shareInput.inputStr2
        // host the SwiftU view
        let extensionView = ShareExtensionView(extensionContext: self.extensionContext,
                                                    returnArray: self.$returnArray,
                                                           text: text)
        let contentView = UIHostingController(rootView: extensionView)
        self.addChild(contentView)
        self.view.addSubview(contentView.view)
        // set up constraints
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true

        self.observer = self.center.addObserver(forName: .closeExtension, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.done()
            }
        }
    }

    // called when HostApp uses ShareLink
    func loadTransferable(_ itemProvider: NSItemProvider) {
        let progress = itemProvider.loadTransferable(type: ShareInput.self) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .failure(let error):
                    self.logger.error("---->failure: \(error.localizedDescription)")
                case .success(let shareInput):
                    let inputStr2 = shareInput.inputStr2
                    self.logger.log("---->Success: \(inputStr2)")
                    // if we get here, we're good and can show the View :D
                    DispatchQueue.main.async {
                        self.addShareExtensionView(shareInput)
                    }
            }
        }
    }

    // called when HostApp uses UIActivityViewController
    func loadItemSource(_ itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: inputItemSourceType, options: nil) { [weak self] (input, error) in
            guard error == nil else { self?.cancel(error: error!); return }

            if let self {
                do {
//                  let str = String(decoding: input as! Data, as: UTF8.self)
                    let itemSource = try JSONDecoder().decode(InputItemSource.self, from: input as! Data)
                    // if we get here, we're good and can show the View :D
                    DispatchQueue.main.async {
                        self.addShareExtensionView(itemSource.shareInput)
                    }
                    // done, extension is now showing the data
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
            } else {
//                self.logger.error("❗️❗️Yikes - no self")     // can't log since we don't have self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = extensionItem.attachments?.first {
//                logger.log("❗️itemProvider=\(itemProvider)")
                if itemProvider.hasItemConformingToTypeIdentifier(shareInputType) {
                    loadTransferable(itemProvider)
                } else if itemProvider.hasItemConformingToTypeIdentifier(inputItemSourceType) {
                    loadItemSource(itemProvider)
                } else {
                    logger.error("❗️❗️Neither ShareInput nor inputItemSource ❗️❗️")
                    cancel(error: SharingError.inputItemError)
                }
            } else {
                logger.error("❗️❗️No itemProvider ❗️❗️")
                cancel(error: SharingError.inputItemAttachmentError)
            }
        } else {
            logger.error("❗️❗️No extensionItem ❗️❗️")
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
