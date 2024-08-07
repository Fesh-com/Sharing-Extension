//
//  HostContentView.swift
//  HostSwiftUI
//
//  Created by Marc Stibane on 2024-07-03.
//
import SwiftUI

struct HostContentView: View {
    @State private var showActivityView = false

    var body: some View {
        let previewTitle = "Choose the ContainingApp"
        let image = UIImage(systemName: "arrowshape.right.fill")
        let preview = SharePreview(previewTitle, image: Image(uiImage: image!))

        let shareInput = ShareInput(inputStr1: "prefix",
                                    inputStr2: "ShareInput string",
                                    inputStr3: "suffix")

        VStack(spacing: 25.0) {
            Spacer()
            Text("HostSwiftUI")

            // Note that ShareLink can share the input struct directly...
            ShareLink("ShareLink", item: shareInput, preview: preview)

            Button(action: { showActivityView = true }) {
                Image(systemName: "square.and.arrow.up")
                    .accessibility(hidden: true)
                Text("ActivityViewController")
            }
            .sheet(isPresented: $showActivityView) {
                // ... while ActivityViewController needs it packed with an NSItemProvider
                let itemSource = InputItemSource(shareInput: shareInput, previewTitle: previewTitle, previewImage: image!)
                let configuration = UIActivityItemsConfiguration(objects: [itemSource])
                ActivityViewController(configuration: configuration)
                    .presentationDetents([.medium])
            }
            Spacer()
            Spacer()
        }
        .font(.title)
        .buttonStyle(.bordered)
    }
}

//#Preview {
//    HostContentView()
//}
