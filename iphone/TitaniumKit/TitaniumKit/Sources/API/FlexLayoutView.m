//
//  FlexLayoutView.m
//  TitaniumKit
//
//  Created by Jan Vennemann on 20.11.19.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

@import StretchKit;

#import "FlexLayoutView.h"
#import "TiViewProxy.h"

#import <TitaniumKit/TitaniumKit-Swift.h>

@implementation FlexLayoutView

- (void)setNeedsLayout
{
  [self.proxy.layoutService computeLayout];

  [super setNeedsLayout];
}

- (void)layoutSubviews
{
  FlexLayoutService *layoutService = self.proxy.layoutService;
  for (UIView *view in self.subviews) {
    [layoutService applyLayoutForView:view];
  }
}

@end
