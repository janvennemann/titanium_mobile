//
//  LayoutContext.swift
//  TitaniumKit
//
//  Created by Jan Vennemann on 16.03.20.
//  Copyright © 2020 Hans Knoechel. All rights reserved.
//

import Combine
import Foundation
import StretchKit

@objc
public class LayoutContext : NSObject {
  var proxy: TiViewProxy
  
  @objc
  public var parent: TiViewProxy? {
    didSet {
      if let cancallable = self.styleCancellable {
        cancallable.cancel()
      }
      
      if let oldParent = oldValue {
        oldParent.layoutContext.node.removeChild(self.node);
      }
      
      guard let parent = parent else {
        return
      }
      
      parent.layoutContext.node.addChild(self.node);
      self.applyStyle()
      
      if let cancallable = self.styleCancellable {
        cancallable.cancel()
      }
      self.styleCancellable = self.style.objectWillChange
        .debounce(for: .milliseconds(20), scheduler: RunLoop.main)
        .sink { _ in
          self.applyStyle()
          if let parentView = parent.view {
            parentView.setNeedsLayout()
          }
          if let view = self.proxy.view {
            view.setNeedsLayout()
          }
        }
    }
  }
  
  var style: CssStyle {
    get {
      self.proxy.style.style
    }
  }
  
  var styleCancellable: AnyCancellable?
  
  var node: Node
  
  @objc
  init(withProxy proxy: TiViewProxy) {
    self.proxy = proxy
    self.node = LayoutNodeFactory.defaultFactory.createLayoutNode(forProxy: proxy)
    
    super.init()
  }
  
  func computeLayout(thatFits size: Size<Float?>) -> Layout {
    return self.node.computeLayout(thatFits: size)
  }
  
  @objc
  func applyStyle() {
    let view = self.proxy.view
    // TODO: apply other styles not handled by Stretch
    if let backgroundColor = self.style.backgroundColor {
      view?.backgroundColor = backgroundColor
    }
    
    self.applyStretchStyle()
  }
  
  private func applyStretchStyle() {
    self.node.style = self.style.stretchStyle
  }
}
