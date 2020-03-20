/**
* Appcelerator Titanium Mobile
* Copyright (c) 2019-present by Appcelerator, Inc. All Rights Reserved.
* Licensed under the terms of the Apache Public License
* Please see the LICENSE included with this distribution for details.
*/

import Foundation
import Combine
import StretchKit

public class CssStyle: ObservableObject {
  @Published var width = Dimension.auto
  @Published var height = Dimension.auto
  @Published var flexGrow: Float = 0.0
  @Published var flexShrink: Float = 1.0
  @Published var flexBasis = Dimension.auto
  @Published var flexDirection = FlexDirection.row
  @Published var flexWrap = FlexWrap.noWrap
  @Published var justifyContent = JustifyContent.flexStart
  @Published var alignItems = AlignItems.stretch
  @Published var paddingTop = Dimension.undefined
  @Published var paddingRight = Dimension.undefined
  @Published var paddingBottom = Dimension.undefined
  @Published var paddingLeft = Dimension.undefined
  @Published var marginTop = Dimension.undefined
  @Published var marginRight = Dimension.undefined
  @Published var marginBottom = Dimension.undefined
  @Published var marginLeft = Dimension.undefined
  @Published var position = PositionType.relative
  @Published var top = Dimension.undefined
  @Published var right = Dimension.undefined
  @Published var bottom = Dimension.undefined
  @Published var left = Dimension.undefined
  @Published var backgroundColor: UIColor?
  @Published var backgroundImage: String?
  
  var stretchStyle: Style {
    get {
      return Style(
        positionType: self.position,
        flexDirection: self.flexDirection,
        flexWrap: self.flexWrap,
        alignItems: self.alignItems,
        justifyContent: self.justifyContent,
        position: Rect(
          start: self.left,
          end: self.right,
          top: self.top,
          bottom: self.bottom
        ),
        margin: Rect(
          start: self.marginLeft,
          end: self.marginRight,
          top: self.marginTop,
          bottom: self.marginBottom
        ),
        padding: Rect(
          start: self.paddingLeft,
          end: self.paddingRight,
          top: self.paddingTop,
          bottom: self.paddingBottom
        ),
        flexGrow: self.flexGrow,
        flexShrink: self.flexShrink,
        flexBasis: self.flexBasis,
        size: Size(width: self.width, height: self.height)
      )
    }
  }
  
  func flex(grow: Float) {
    self.flex(grow: grow, shrink: 1.0, basis: .auto)
  }
  
  func flex(grow: Float, shrink: Float) {
    self.flex(grow: grow, shrink: shrink, basis: .auto)
  }
  
  func flex(grow: Float, shrink: Float, basis: StretchKit.Dimension) {
    self.flexGrow = grow
    self.flexShrink = shrink
    self.flexBasis = basis
  }
  
  func margin(x: StretchKit.Dimension) {
    self.marginTop = Dimension.undefined
    self.marginBottom = Dimension.undefined
    self.marginLeft = x
    self.marginRight = x
  }
  
  func margin(y: StretchKit.Dimension) {
    self.marginTop = y
    self.marginBottom = y
    self.marginLeft = Dimension.undefined
    self.marginRight = Dimension.undefined
  }
}
