//
//  LayoutNodeFactory.swift
//  TitaniumKit
//
//  Created by Jan Vennemann on 30.03.20.
//  Copyright © 2020 Hans Knoechel. All rights reserved.
//

import Foundation
import StretchKit

public class LayoutNodeFactory : NSObject {
  public static let defaultFactory = LayoutNodeFactory()
  
  var factories: [String: (TiViewProxy) -> Node] = [:];
  
  private override init() {

  }
  
  public func registerFactory(forView viewName: String, factory: @escaping (TiViewProxy) -> Node) {
    self.factories[viewName] = factory;
  }
  
  public func createLayoutNode(forProxy proxy: TiViewProxy) -> Node {
    let apiName = proxy.apiName()!
    guard let factory = self.factories[apiName] else {
      return self.createDefaultLayoutNode(proxy)
    }
    return factory(proxy);
  }
  
  private func createDefaultLayoutNode(_ proxy: TiViewProxy) -> Node {
    return Node(
      style: proxy.style.style.stretchStyle,
      children: []
    )
  }
}
