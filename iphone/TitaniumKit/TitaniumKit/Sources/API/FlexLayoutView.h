//
//  FlexLayoutView.h
//  TitaniumKit
//
//  Created by Jan Vennemann on 20.11.19.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class TiViewProxy;

@interface FlexLayoutView : UIView

@property (nonatomic, readwrite, assign) TiViewProxy *proxy;

@end

NS_ASSUME_NONNULL_END
