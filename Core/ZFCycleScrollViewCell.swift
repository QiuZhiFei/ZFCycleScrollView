//
//  ZFCycleScrollViewCell.swift
//  ZFCycleScrollView
//
//  Created by ZhiFei on 2018/10/12.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

public class ZFCycleScrollViewCell: UICollectionViewCell {
  
  public var itemView: UIView?
 
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
