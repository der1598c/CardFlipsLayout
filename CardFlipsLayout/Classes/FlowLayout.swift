//
//  FlowLayout.swift
//  CardFlipsLayout
//
//  Created by der1598c on 08/19/2019.
//  Copyright (c) 2019 der1598c. All rights reserved.
//

import UIKit

open class FlowLayout: UICollectionViewFlowLayout {
    
    fileprivate var lastCollectionViewSize: CGSize = CGSize.zero
    
    var scaleOffset: CGFloat = 200
    var scaleFactor: CGFloat = 0.9
    var alphaFactor: CGFloat = 0.3
    var lineSpacing: CGFloat = 25.0
    
    public init(itemSize: CGSize) {
        super.init()
        self.itemSize = itemSize
        minimumLineSpacing = lineSpacing
        scrollDirection = .horizontal
    }
    
    required public init?(coder _: NSCoder) {
        fatalError()
    }
    
    func setItemSize(itemSize: CGSize) {
        self.itemSize = itemSize
    }
    
    override open func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        guard let collectionView = self.collectionView else { return }
        
        if collectionView.bounds.size != lastCollectionViewSize {
            configureContentInset()
            lastCollectionViewSize = collectionView.bounds.size
        }
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        
        let proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        guard let layoutAttributes = self.layoutAttributesForElements(in: proposedRect) else {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionView.bounds.width / 2
        
        for attributes in layoutAttributes {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        guard let aCandidateAttributes = candidateAttributes else {
            return proposedContentOffset
        }
        
        var newOffsetX = aCandidateAttributes.center.x - collectionView.bounds.size.width / 2
        let offset = newOffsetX - collectionView.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = itemSize.width + minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
    
    override open func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView,
            let superAttributes = super.layoutAttributesForElements(in: rect) else {
                return super.layoutAttributesForElements(in: rect)
        }
        
        let contentOffset = collectionView.contentOffset
        let size = collectionView.bounds.size
        
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterX = visibleRect.midX
        
        guard case let newAttributesArray as [UICollectionViewLayoutAttributes] = NSArray(array: superAttributes, copyItems: true) else {
            return nil
        }
        
        newAttributesArray.forEach {
            let distanceFromCenter = visibleCenterX - $0.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scaleOffset)
            let scale = absDistanceFromCenter * (self.scaleFactor - 1) / self.scaleOffset + 1
            $0.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            
            let alpha = absDistanceFromCenter * (self.alphaFactor - 1) / self.scaleOffset + 1
            $0.alpha = alpha
        }
        
        return newAttributesArray
    }
    
    func configureContentInset() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.contentOffset = CGPoint(x: -inset, y: 0)
    }
    
    func resetContentInset() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}
