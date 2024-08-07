//
//  ShareExtensionView.swift
//  ShareExtension
//
//  Created by Marc Stibane on 2024-07-04.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension NSNotification.Name {
    static let closeExtension = Self(rawValue: "ShareExtension_close")
}
// MARK: -
struct ShareExtensionView: View {
    var extensionContext: NSExtensionContext?
    @Binding var returnArray: [NSExtensionItem]
    @State private var text: String

    init(extensionContext: NSExtensionContext?, returnArray: Binding<[NSExtensionItem]>, text: String) {
        self.extensionContext = extensionContext
        self._returnArray = returnArray
        self.text = text
    }

    func complete(result: ShareResult) {
        let itemSource = ResultItemSource(shareResult: result)
        let returnProvider = NSItemProvider(object: itemSource)
//                                  typeIdentifier: UTType.shareResult.identifier)

        // a Swift string can be returned as NSString
//        let returnProvider = NSItemProvider(item: result.outputStr1 as NSString,
//                                  typeIdentifier: UTType.text.identifier)

        let returnItem = NSExtensionItem()
        returnItem.attachments = [returnProvider]
        // Signals the host to complete the app extension request with the supplied result items.
        // The completion handler optionally contains any work which the extension may need to perform
        // after the request has been completed, as a background-priority task.
        //   The `expired` parameter will be YES if the system decides to prematurely terminate a previous
        //   non-expiration invocation of the completionHandler.
        // Note: calling this method will eventually dismiss the associated view controller.
        returnArray.append(returnItem)
        self.extensionContext!.completeRequest(returningItems: [returnItem],
                                            completionHandler: nil)
        NotificationCenter.default.post(name: .closeExtension, object: nil)
    }

    func cancel() {
        // Signals the host to cancel the app extension request, with the supplied error, which should be non-nil.
        // The userInfo of the NSError will contain a key NSExtensionItemsAndErrorsKey which will have
        // as its value a dictionary of NSExtensionItems and associated NSError instances.
//        let error = JSONParsingError.invalidData
        let error = NSError(domain: "com.fesh.containingdemo.ShareExtension",
                            code: 0, userInfo: [NSLocalizedDescriptionKey: "An error occured"])
        self.extensionContext!.cancelRequest(withError: error)
    }

    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                TextField("Text", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)

                Button {
                    // returns the 'text' back to the host
                    let shareResult = ShareResult(outputStr1: text, outputStr2: "Modified by ShareExtension")
                    complete(result: shareResult)
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Share Extension")
            .toolbar {
                Button("Cancel") {
                    cancel()
                }
            }
        }
    }
}

//#Preview {
//    ShareExtensionView(extensionContext: nil, text: "Hello world")
//}
