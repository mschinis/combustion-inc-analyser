//
//  ShareViewController.swift
//  CombAnalyserShareExtension
//
//  Created by Michael Schinis on 27/03/2024.
//

//import UIKit
//import Social
//
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
////    override func configurationItems() -> [Any]! {
////        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
////        return []
////    }
//
//}

import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure access to extensionItem and itemProvider
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        // Check type identifier
        let textDataType = UTType.plainText.identifier
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {

            // Load the item from itemProvider
            itemProvider.loadItem(forTypeIdentifier: textDataType , options: nil) { (providedText, error) in
                  if let error {
                      self.close()
                      return
                  }
                
                if let text = providedText as? String {
                    DispatchQueue.main.async {
                        // host the SwiftU view
                        let contentView = UIHostingController(rootView: ShareExtensionView(text: text))
                        self.addChild(contentView)
                        self.view.addSubview(contentView.view)
                        
                        // set up constraints
                        contentView.view.translatesAutoresizingMaskIntoConstraints = false
                        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                        contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
                        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                        contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
                    }
                } else {
                    self.close()
                    return
                }
                
            }

        } else {
            close()
            return
        }
       
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
    }
    
    /// Close the Share Extension
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
