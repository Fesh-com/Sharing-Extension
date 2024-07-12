//
//  UTType+SharingData.swift
//  Common
//
//  Created by Marc Stibane on 2024-07-04.
//
import Foundation
import CoreTransferable
import UniformTypeIdentifiers

let shareInput: UTType = .shareInput
let shareResult: UTType = .shareResult

extension UTType {
    static let shareInput: UTType   = UTType(exportedAs: "com.fesh.shareInput")
    static let shareResult: UTType  = UTType(exportedAs: "com.fesh.shareResult")
}
