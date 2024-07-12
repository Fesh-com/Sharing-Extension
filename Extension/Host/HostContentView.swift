//
//  HostContentView.swift
//  Host
//
//  Created by Marc Stibane on 2024-07-03.
//
import SwiftUI

struct HostContentView: View {
    var body: some View {
        let preview = SharePreview("shareInput", image: Image(systemName: "arrowshape.right.fill"))
        let shareInput = ShareInput(inputStr: "ShareInput as JSON")

        VStack(spacing: 25.0) {
            Text("HostApp!")
            ShareButton(title: "Text", shareItems: [ItemSource(dataToShare: "sharing some text")])
            ShareButton(title: "JSON", shareItems: [ItemSource(dataToShare: shareInput)
                                                   ,ItemSource(dataToShare: "sharing some text")
                                                   ])
            ShareLink("ShareLink", item: shareInput, preview: preview)
        }
        .font(.title)
        .buttonStyle(.bordered)
    }
}

#Preview {
    HostContentView()
}
