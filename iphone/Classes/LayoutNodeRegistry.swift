//
//  LayoutNodeRegistry.swift
//  Titanium
//
//  Created by Jan Vennemann on 30.03.20.
//

import Foundation
import TitaniumKit
import StretchKit

@objc
class LayoutNodeRegistry : NSObject {
  @objc
  public static let defaultRegistry = LayoutNodeRegistry()
  
  private override init() {
    
  }
  
  @objc
  func registerDefaultFactories() {
    let factory = LayoutNodeFactory.defaultFactory;
    
    factory.registerFactory(forView: "Ti.UI.Label") { (proxy) -> Node in
      return Node(
        style: Style(),
        measure: { (size: Size<Float?>) -> Size<Float> in
          let view = (proxy as! TiUILabelProxy).view as! TiUILabel
          let contentSize = view.label().intrinsicContentSize
          // FIXME: Sometimes these values don't really fit
          let width = Float(contentSize.width) + 0.75
          let height = Float(contentSize.height) + 0.75
          return Size(
            width: width,
            height: height
          )
        }
      )
    }
  }
}
