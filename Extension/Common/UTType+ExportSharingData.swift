//
//  UTType+SharingData.swift
//  SharingExtension
//
//  Created by Marc Stibane on 2024-07-04.
//
import Foundation
import CoreTransferable
import UniformTypeIdentifiers

let shareInput: UTType = .shareInput
let shareResult: UTType = .shareResult
let inputItemSource: UTType = .inputItemSource
let resultItemSource: UTType = .resultItemSource

/// The export definition of our used types for the Containing application and the ShareExtension
extension UTType {
    static let shareInput: UTType       = UTType(exportedAs: "com.fesh.shareinput")
    static let shareResult: UTType      = UTType(exportedAs: "com.fesh.shareresult")
    static let inputItemSource: UTType  = UTType(exportedAs: "com.fesh.inputitemsource")
    static let resultItemSource: UTType = UTType(exportedAs: "com.fesh.resultitemsource")
}
