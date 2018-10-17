//
//  ViewController.swift
//  ZFCycleScrollViewExample
//
//  Created by ZhiFei on 2018/10/16.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import UIKit
import ZFCycleScrollView

class ViewController: UIViewController {
  
  fileprivate let datasCount = 2
  
  fileprivate let cy = ZFCycleScrollView(frame: CGRect(x: 20, y: 100, width: 280, height: 200))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cy.layer.borderColor = UIColor.red.cgColor
    cy.layer.borderWidth = 1
    
    self.view.addSubview(cy)
    cy.configure(datasCount: datasCount)
    
    cy.displayItemHandler = {
      [weak self] (cell, index) in
      guard let `self` = self else { return }
      debugPrint("display index == \(index), cur == \(self.cy.currentIndex)")
      if cell.itemView == nil {
        let itemView = ZFCycleScrollItemView(frame: .zero)
        cell.itemView = itemView
        
        cell.contentView.addSubview(itemView)
        itemView.autoPinEdgesToSuperviewEdges(with: .zero)
      }
      if let itemView = cell.itemView as? ZFCycleScrollItemView {
        itemView.configure(text: "\(index)")
      }
    }
    cy.didSelectItemHandler = {
      [weak self] (index) in
      guard let `self` = self else { return }
      debugPrint("did select \(index)")
    }
    cy.currentIndexChangedHandler = {
      [weak self] (oldIndex, index) in
      guard let `self` = self else { return }
      debugPrint("\(oldIndex) scroll to \(index)")
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    if cy.endType == .center {
      cy.configure(endType: .left)
    } else {
      cy.configure(endType: .center)
    }
    
    cy.configure(datasCount: datasCount)
  }

}

