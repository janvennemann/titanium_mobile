//
//  FlexLayoutViewProxy.swift
//  TitaniumKit
//
//  Created by Jan Vennemann on 20.11.19.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

import Combine
import Foundation
import StretchKit

/*

public protocol FlexLayoutViewProxy {
  var parent: FlexLayoutViewProxy { get set }
  
  func getLayoutService() -> FlexLayoutService
  func createLayoutNode()
  func applyStyle()
}

public extension FlexLayoutViewProxy where Self: TiUIView {
  
}

public class FlexLayoutViewProxy : TiProxy {
  lazy var node: Node = {
    return self.createLayoutNode()
  }()
  
  var style = CssStyle()
  
  var parent: FlexLayoutViewProxy? {
    didSet {
      guard let parent = parent else {
        return
      }
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
          if let view = self.view {
            view.setNeedsLayout()
          }
        }
    }
  }
  
  var view: FlexLayoutView?
  
  var styleCancellable: AnyCancellable?
  
  func getLayoutService() -> FlexLayoutService {
    guard let parent = self.parent else {
      fatalError("Could not get LayoutService, no parent found")
    }
    return parent.getLayoutService()
  }
  
  func createLayoutNode() -> Node {
    return Node(
      style: self.style.sketchStyle,
      children: []
    )
  }
  
  func applyStyle() {
    self.applySketchStyle()
  }
  
  private func applySketchStyle() {
    self.node.style = self.style.sketchStyle
  }
}
*/
