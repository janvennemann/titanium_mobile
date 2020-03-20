//
//  StyleProxy.swift
//  TitaniumKit
//
//  Created by Jan Vennemann on 16.03.20.
//  Copyright © 2020 Hans Knoechel. All rights reserved.
//

import Foundation
import StretchKit

public class StyleProxy : TiProxy {
  public var style: CssStyle!
  
  private var context: JSContext!
  
  private var _backgroundColor: String?
  
  @objc
  var backgroundColor: Any {
    get {
      if let colorString = _backgroundColor {
        return colorString
      }
      
      return self.value(forUndefinedKey: "backgroundColor") as Any
    }
    set(newValue) {
      if let colorString = newValue as? String {
        if (colorString.hasPrefix("#")) {
          self.style.backgroundColor = Webcolor.color(forHex: colorString)
        } else {
          self.style.backgroundColor = Webcolor.webColorNamed(colorString)
        }
        _backgroundColor = colorString
      } else {
        self.setValue(newValue, forUndefinedKey: "backgroundColor");
      }
    }
  }
  
  public override func _configure() {
    self.style = CssStyle();
    self.context = JSContext(jsGlobalContextRef: JSContextGetGlobalContext(self.pageContext.krollContext()?.context()))
  }
}

// MARK: Position

@objc
extension StyleProxy {
  @objc
  var width: Any {
    get {
      switch self.style.width {
      case .auto:
        return "auto"
      case .percent(let percent):
        return percent
      case .points(let points):
        return points
      case .undefined:
        return JSValue(undefinedIn: self.context)!
      }
    }
    set(newValue) {
      if let stringValue = newValue as? NSString {
        if (stringValue == "auto") {
          self.style.width = .auto;
        } else {
          let percentValueString = stringValue.trimmingCharacters(in: ["%"])
          if let percentValue = Float(percentValueString) {
            self.style.width = .percent(percentValue / 100.0)
          } else {
            self.style.width = .auto
          }
        }
      } else if let numberValue = newValue as? NSNumber {
        self.style.width = .points(numberValue.floatValue)
      } else {
        self.style.width = .undefined
      }
    }
  }
  
  @objc
  var height: Any {
    get {
      switch self.style.height {
      case .auto:
        return "auto"
      case .percent(let percent):
        return percent
      case .points(let points):
        return points
      case .undefined:
        return JSValue(undefinedIn: self.context)!
      }
    }
    set(newValue) {
      if let stringValue = newValue as? NSString {
        if (stringValue == "auto") {
          self.style.height = .auto;
        } else {
          let percentValueString = stringValue.trimmingCharacters(in: ["%"])
          if let percentValue = Float(percentValueString) {
            self.style.height = .percent(percentValue / 100.0)
          } else {
            self.style.height = .auto
          }
        }
      } else if let numberValue = newValue as? NSNumber {
        self.style.height = .points(numberValue.floatValue)
      } else {
        self.style.height = .undefined
      }
    }
  }
  
  @objc
  var top: Any {
    get {
      switch self.style.top {
      case .auto:
        return "auto"
      case .percent(let percent):
        return percent
      case .points(let points):
        return points
      case .undefined:
        return JSValue(undefinedIn: self.context)!
      }
    }
    set(newValue) {
      if let stringValue = newValue as? NSString {
        if (stringValue == "auto") {
          self.style.top = .auto;
        } else {
          // TODO: Parse percent value
          self.style.top = .percent(0);
        }
      } else if let numberValue = newValue as? NSNumber {
        self.style.top = .points(numberValue.floatValue)
      } else {
        self.style.top = .undefined
      }
    }
  }
}

// MARK: Margin / Padding

@objc
extension StyleProxy {
  @objc
  var paddingTop: Any {
    get {
      return JSValue(undefinedIn: self.context)!
    }
    set (newValue) {
      if let numberValue = newValue as? Float {
        self.style.paddingTop = .points(numberValue)
      }
    }
  }
}

// MARK: Flex box

@objc
extension StyleProxy {
  @objc
  var flexGrow: Float {
    get {
      return self.style.flexGrow
    }
    set(newValue) {
      self.style.flexGrow = newValue
    }
  }
  
  @objc
  var justifyContent: String {
    get {
      switch self.style.justifyContent {
      case .center:
        return "center"
      case .flexEnd:
        return "flex-end"
      case .flexStart:
        return "flex-start"
      case .spaceAround:
        return "space-around"
      case .spaceBetween:
        return "space-around"
      case .spaceEvenly:
        return "space-evenly"
      }
    }
    set (newValue) {
      if (newValue == "center") {
        self.style.justifyContent = .center
      } else if (newValue == "flex-end") {
        self.style.justifyContent = .flexEnd
      } else if (newValue == "flex-start") {
        self.style.justifyContent = .flexStart
      } else if (newValue == "space-around") {
        self.style.justifyContent = .spaceAround
      } else if (newValue == "space-between") {
        self.style.justifyContent = .spaceBetween
      } else if (newValue == "space-evenly") {
        self.style.justifyContent = .spaceEvenly
      } else {
        self.style.justifyContent = .flexStart
      }
    }
  }
  
  @objc
  var alignItems: String {
    get {
      switch self.style.alignItems {
      case .baseline:
        return "baseline"
      case .center:
        return "center"
      case .flexEnd:
        return "flex-end"
      case .flexStart:
        return "flex-start"
      case .stretch:
        return "stretch"
      }
    }
    set (newValue) {
      if (newValue == "baseline") {
        self.style.alignItems = .baseline
      } else if (newValue == "center") {
        self.style.alignItems = .center
      } else if (newValue == "flex-end") {
        self.style.alignItems = .center
      } else if (newValue == "flex-start") {
        self.style.alignItems = .flexStart
      } else if (newValue == "stretch") {
        self.style.alignItems = .stretch
      } else {
        self.style.alignItems = .stretch
      }
    }
  }
  
  @objc
  var flexDirection: String {
    get {
      return "bla"
    }
    set (newValue) {
      if (newValue == "column") {
        self.style.flexDirection = .column
      }
    }
  }
  
  @objc
  var flexWrap: String {
    get {
      return "bla"
    }
    set (newValue) {
      if newValue == "nowrap" {
        self.style.flexWrap = .noWrap
      } else if newValue == "wrap" {
        self.style.flexWrap = .wrap
      }
    }
  }
}
