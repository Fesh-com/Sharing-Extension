//
//  UTType+SharingData.swift
//  HostSwiftUI + HostUIKit
//
//  Created by Marc Stibane on 2024-07-24.
//
import Foundation
import CoreTransferable
import UniformTypeIdentifiers

let shareInput: UTType = .shareInput
let shareResult: UTType = .shareResult
let inputItemSource: UTType = .inputItemSource
let resultItemSource: UTType = .resultItemSource

/// The import definition of our used types for the Host application(s)
extension UTType {
    static let shareInput: UTType       = UTType(importedAs: "com.fesh.shareinput")
    static let shareResult: UTType      = UTType(importedAs: "com.fesh.shareresult")
    static let inputItemSource: UTType  = UTType(importedAs: "com.fesh.inputitemsource")
    static let resultItemSource: UTType = UTType(importedAs: "com.fesh.resultitemsource")
}
