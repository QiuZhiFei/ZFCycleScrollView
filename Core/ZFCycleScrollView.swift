//
//  ZFCycleScrollView.swift
//  ZFCycleScrollView
//
//  Created by ZhiFei on 2018/10/12.
//  Copyright © 2018 ZhiFei. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import KVOController

fileprivate let numberOfItems: Int = 3
fileprivate let ZFCycleScrollViewCellID = "ZFCycleScrollViewCellID"

public enum ZFCycleScrollViewEndType {
  case center
  case left
}

public class ZFCycleScrollView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
  
  public var displayItemHandler: ((_ cell: ZFCycleScrollViewCell, _ index: Int) -> ())?
  public var didSelectItemHandler: ((_ index: Int) -> ())?
  public var currentIndex: Int {
    return self.curIndex
  }
  public var currentIndexChangedHandler: ((_ oldIndex: Int, _ index: Int) -> ())?
  
  public fileprivate(set) var endType: ZFCycleScrollViewEndType = .center
  
  fileprivate var itemsCount: Int = 0 // item 数量
  fileprivate var datasCount: Int = 0 // data 数量
  fileprivate var curIndex: Int = 0
  fileprivate var startIndex: Int = 0
  
  fileprivate let flowLayout = UICollectionViewFlowLayout()
  fileprivate var contentView: UICollectionView!
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: Overwrite
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    flowLayout.itemSize = contentView.bounds.size
  }
  
  //MARK: UICollectionViewDataSource && UICollectionViewDelegate
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemsCount
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZFCycleScrollViewCellID, for: indexPath)
    if let cell = cell as? ZFCycleScrollViewCell {
      let index = self.getCurrentIndex(indexPath: indexPath)
      if let handler = self.displayItemHandler {
        handler(cell, index)
      }
    }
    
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let index = self.getCurrentIndex(indexPath: indexPath)
    if let handler = self.didSelectItemHandler {
      handler(index)
    }
  }
  
  //MARK: UIScrollViewDelegate
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.scrollingEnded()
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.scrollingEnded()
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    self.perform(#selector(ZFCycleScrollView.scrollingEnded),
                 with: nil,
                 afterDelay: 0)
  }
  
}

public extension ZFCycleScrollView {
  
  func configure(endType: ZFCycleScrollViewEndType) {
    self.endType = endType
  }
  
  func configure(datasCount: Int) {
    if datasCount == 0 {
      self.itemsCount = 0
      self.datasCount = 0
    } else {
      self.datasCount = datasCount
      if datasCount < numberOfItems {
        self.itemsCount = datasCount
      } else {
        self.itemsCount = numberOfItems
      }
    }
    
    var startIndex = 0
    switch endType {
    case .center:
      startIndex = self.itemsCount / 2
    case .left:
      startIndex = 0
    }
    self.startIndex = startIndex
    
    self.contentView.reloadData()
    self.resetContentView()
  }
  
}

fileprivate extension ZFCycleScrollView {
  
  func setup() {
    flowLayout.minimumLineSpacing = 0
    flowLayout.scrollDirection = .horizontal
    
    contentView = UICollectionView(frame: .zero,
                                   collectionViewLayout: flowLayout)
    contentView.backgroundColor = UIColor.clear
    contentView.isPagingEnabled = true
    contentView.scrollsToTop = false
    contentView.showsHorizontalScrollIndicator = false
    contentView.showsVerticalScrollIndicator = false
    contentView.register(ZFCycleScrollViewCell.self,
                         forCellWithReuseIdentifier: ZFCycleScrollViewCellID)
    
    contentView.dataSource = self
    contentView.delegate = self
    
    self.addSubview(contentView)
    contentView.autoPinEdgesToSuperviewEdges(with: .zero)
    contentView.backgroundColor = .clear
    
    // 滚动到中间位置
    self.kvoController
      .observe(contentView,
               keyPath: "contentSize",
               options: [.new, .initial]) {
                [weak self] (viewController, viewModel, change) in
                guard let `self` = self else { return }
                let contentSize = self.contentView.contentSize
                if contentSize.width == 0 {
                  return
                }
                if contentSize.height == 0 {
                  return
                }
                self.kvoController.unobserve(self.contentView)
                self.resetContentView()
    }
  }
  
  func getCurrentIndex(indexPath: IndexPath) -> Int {
    let row = indexPath.row
    let index = self.curIndex + row - self.startIndex
    
    if index == self.datasCount {
      return 0
    }
    if index < 0 {
      return self.datasCount - 1
    }
    
    return index
  }
  
  @objc func scrollingEnded() {
    let oldIndex = self.curIndex
    
    let point = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    let center = self.convert(point, to: self.contentView)
    guard let indexPath = self.contentView.indexPathForItem(at: center) else {
      return
    }
    
    if indexPath.row > self.startIndex {
      self.curIndex = self.curIndex == self.datasCount - 1 ? 0 : self.curIndex + 1
    }
    if indexPath.row < self.startIndex {
      self.curIndex = self.curIndex == 0 ? self.datasCount - 1 : self.curIndex - 1
    }
    
    self.contentView.reloadData()
    self.resetContentView()
    
    if let handler = self.currentIndexChangedHandler {
      handler(oldIndex, self.currentIndex)
    }
  }
  
  func resetContentView() {
    if itemsCount > 0 {
      let indexPath = IndexPath(item: self.startIndex, section: 0)
      contentView.scrollToItem(at: indexPath,
                               at: .centeredHorizontally,
                               animated: false)
    }
  }
  
}


