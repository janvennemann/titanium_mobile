/**
* Appcelerator Titanium Mobile
* Copyright (c) 2019-present by Appcelerator, Inc. All Rights Reserved.
* Licensed under the terms of the Apache Public License
* Please see the LICENSE included with this distribution for details.
*/

import Combine
import Foundation
import StretchKit

/*
public class FlexLayoutView : UIView {
  var proxy: FlexLayoutViewProxy?
  
  func add(_ view: FlexLayoutView) {
    self.node.addChild(view.node)
    view.parent = self
    view.applyStyle()
    self.addSubview(view)
  }
  
  override public func setNeedsLayout() {
    if let proxy = self.proxy {
      proxy.getLayoutService().computeLayout()
    }
    super.setNeedsLayout()
  }
  
  override public func layoutSubviews() {
    print("layoutSubviews \(String(describing: self))")
    guard let proxy = self.proxy else {
      return
    }
    let layoutService = proxy.getLayoutService()
    for view in self.subviews {
      let layout = layoutService.layout(forView: view)
      view.frame = rectFromLayout(layout)
    }
  }
}

public extension FlexLayoutView {
  override func setNeedsLayout() {
    guard let proxy = self.proxy as? TiViewProxy else {
      return
    }
    proxy.layoutService.computeLayout()
    super.setNeedsLayout()
  }
  
  override func layoutSubviews() {
    print("layoutSubviews \(String(describing: self))")
    guard let proxy = self.proxy as? TiViewProxy else {
      return
    }
    let layoutService = proxy.layoutService
    for view in self.subviews {
      let layout = layoutService.layout(forView: view)
      view.frame = rectFromLayout(layout)
    }
  }
}

*/

/*
protocol LayoutNodeFactory {
  func createLayoutNode() -> Node
}

extension LayoutNodeFactory {
  func createDefaultLayoutNode() -> Node {
    return Node(
      style: self.proxy.style.style.stretchStyle,
      children: []
    )
  }
}
*/
