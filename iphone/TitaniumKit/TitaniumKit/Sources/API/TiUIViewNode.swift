//
//  TiUIView.swift
//  TitaniumKit
//
//  Created by Jan Vennemann on 17.03.20.
//  Copyright © 2020 Hans Knoechel. All rights reserved.
//

import Foundation
import StretchKit

extension TiUIView {
  func createDefaultLayoutNode() -> Node {
    return Node(
      style: self.proxy.style.style.stretchStyle,
      children: []
    )
  }
}
