//
//  ZFCycleScrollItemView.swift
//  ZFCycleScrollView
//
//  Created by ZhiFei on 2018/10/16.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class ZFCycleScrollItemView: UIView {
  
  fileprivate let label = UILabel(frame: .zero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension ZFCycleScrollItemView {
  
  func configure(text: String) {
    label.text = text
  }
  
}

fileprivate extension ZFCycleScrollItemView {
  
  func setup() {
    addSubview(label)
    label.autoPinEdgesToSuperviewEdges(with: .zero)
  }
  
}
