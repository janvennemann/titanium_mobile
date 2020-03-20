/**
* Appcelerator Titanium Mobile
* Copyright (c) 2019-present by Appcelerator, Inc. All Rights Reserved.
* Licensed under the terms of the Apache Public License
* Please see the LICENSE included with this distribution for details.
*/

import Foundation
import StretchKit

func rectFrom(_ layout: Layout) -> CGRect {
  return CGRect(
    x: CGFloat(layout.x),
    y: CGFloat(layout.y),
    width: CGFloat(layout.width),
    height: CGFloat(layout.height)
  )
}

public class FlexLayoutService: NSObject {
  @objc
  public var rootView: TiUIView?
  
  var viewToLayoutMap: NSMapTable<UIView, Layout>
  
  var initialized = false
  
  @objc
  public override init() {
    self.viewToLayoutMap = NSMapTable.weakToStrongObjects()
    
    super.init()
  }
  
  @objc
  public func computeLayout() {
    if (!self.initialized) {
      self.initialized = true
    }
    
    guard let rootView = self.rootView, let proxy = rootView.proxy as? TiViewProxy else {
      return
    }
    
    let layout = proxy.layoutContext.node.computeLayout(thatFits: Size(
      width: Float(rootView.frame.width),
      height: Float(rootView.frame.height)
    ))
    
    self.viewToLayoutMap = NSMapTable.weakToStrongObjects()
    self.createLayoutMap(forViews: rootView.subviews, andLayouts: layout.children)
  }
  
  func createLayoutMap(forViews views: [UIView], andLayouts layouts: [Layout]) {
    for (index, layout) in layouts.enumerated() {
      let view = views[index]
      self.viewToLayoutMap.setObject(layout, forKey: view)
      self.createLayoutMap(forViews: view.subviews, andLayouts: layout.children)
    }
  }
  
  func layout(forView view: UIView) -> Layout? {
    if !self.initialized {
      self.computeLayout()
      self.initialized = true
    }
    if let layout = self.viewToLayoutMap.object(forKey: view) {
      return layout
    }
    
    NSLog("No layout found for view %@", view);
    return nil
  }
  
  @objc
  public func applyLayout(forView view: UIView) {
    guard let layout = self.layout(forView: view) else {
      return;
    }
    view.frame = rectFrom(layout)
  }
  
  @objc
  public func rectFromLayout(forView view: UIView) -> CGRect {
    guard let layout = self.layout(forView: view) else {
      return CGRect.zero;
    }
    return rectFrom(layout)
  }
}
