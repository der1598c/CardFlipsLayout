//
//  CollectionViewCell.swift
//  CardFlipsLayout
//
//  Created by der1598c on 08/19/2019.
//  Copyright (c) 2019 der1598c. All rights reserved.
//

import UIKit

private enum State {
    case expanded
    case collapsed
    
    var change: State {
        switch self {
        case .expanded: return .collapsed
        case .collapsed: return .expanded
        }
    }
}

open class CollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addGestureRecognizer(panRecognizer)
    }

    private var cornerRadius: CGFloat = 6
    
    public static let cellSize = CGSize(width: 250, height: 350)
    public static let identifier = "CollectionViewCell"
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var imageImgV: UIImageView!
    @IBOutlet weak var descriptionTxtV: UITextView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var maskImgV: UIImageView!
    @IBOutlet weak var backUiV: UIView!
    
    private var descriptionStr: String!
    
    private var collectionView: UICollectionView?
    private var index: Int?
    
    private var initialFrame: CGRect?
    private var state: State = .collapsed
    private lazy var animator: UIViewPropertyAnimator = {
        //1.
        //        let cubicTiming = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.17, y: 0.67), controlPoint2: CGPoint(x: 0.76, y: 1.0))
        //        return UIViewPropertyAnimator(duration: 0.3, timingParameters: cubicTiming)
        //2.
        //        let springTiming = UISpringTimingParameters(mass: 1.0, stiffness: 2.0, damping: 0.2, initialVelocity: .zero)
        //        return UIViewPropertyAnimator(duration: 0.3, timingParameters: springTiming)
        //Original
        return UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    }()
    
    private let popupOffset: CGFloat = (UIScreen.main.bounds.height - cellSize.height)/2.0
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        
        recognizer.delegate = self
        
        return recognizer
        
    }()
    
    open func configure(with items: Items, collectionView: UICollectionView, index: Int) {
        titleLab.text = items.name
        imageImgV.image = UIImage(named: items.image)
        self.descriptionStr = items.description
        descriptionTxtV.text = self.descriptionStr
        
        self.collectionView = collectionView
        self.index = index
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // y變化量 > x變化量
//Debug code option 1.        print("x:\(abs((panRecognizer.velocity(in: panRecognizer.view)).x)), y:\(abs((panRecognizer.velocity(in: panRecognizer.view)).y))")
//Debug code option 2.        let translation = panRecognizer.translation(in: collectionView)
//        print("ShouldBegin x:\(translation.x), y:\(translation.y))")
        
        return abs((panRecognizer.velocity(in: panRecognizer.view)).y) > abs((panRecognizer.velocity(in: panRecognizer.view)).x)
    }
    
    @objc func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            
        //使用者點擊即觸發至此
        case .began:
            if (state == .expanded) {
                self.maskImgV.image = self.backUiV.genImage()
            }
            
            toggle()
            animator.pauseAnimation()
            
        //使用者點擊後，若有座標位移會觸發至此
        case .changed:
            if (state == .collapsed) {
                self.maskImgV.image = self.backUiV.genImage()
            }
            self.maskImgV.isHidden = false
            self.descriptionTxtV.isHidden = true
            
            let translation = recognizer.translation(in: collectionView)
            var fraction = -translation.y / popupOffset
//            print(".changed -> fraction:\(fraction)")
            
            if (state == .expanded) || (animator.isReversed) { fraction *= -1 }
            animator.fractionComplete = fraction
            
        //使用者放開後會觸發至此
        case .ended:
            let velocity = recognizer.velocity(in: self)
            let shouldComplete = velocity.y > 0
            
            if velocity.y == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            
            switch state {
            case .expanded:
                if !shouldComplete && !animator.isReversed { animator.isReversed = !animator.isReversed }
                if shouldComplete && animator.isReversed { animator.isReversed = !animator.isReversed }
            case .collapsed:
                if shouldComplete && !animator.isReversed { animator.isReversed = !animator.isReversed }
                if !shouldComplete && animator.isReversed { animator.isReversed = !animator.isReversed }
            }
            self.descriptionTxtV.isHidden = false
            self.maskImgV.isHidden = true
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        default:
            ()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        toggle()
    }
    
    open func toggle() {
        switch state {
        case .expanded:
            collapse()
        case .collapsed:
            expand()
        }
    }
    
    open func setCornerRadius(radius: CGFloat) {
        self.cornerRadius = radius
        self.layer.cornerRadius = self.cornerRadius
        self.imageImgV.layer.cornerRadius = self.cornerRadius
    }
    
    private func collapse() {
        guard let collectionView = self.collectionView, let index = self.index else { return }
        
        animator.addAnimations {
            self.descriptionTxtV.alpha = 0
            self.closeBtn.alpha = 0
            
            self.layer.cornerRadius = self.cornerRadius
            self.frame = self.initialFrame!
            
            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
                leftCell.center.x += 50
            }
            
            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
                rightCell.center.x -= 50
            }
            
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                collectionView.isScrollEnabled = true
                collectionView.allowsSelection = true
            default:
                ()
            }
            //因變形後(動畫)會導致字串被換行，故重新填入。
            self.descriptionTxtV.text = self.descriptionStr
            //捲到開頭
            self.descriptionTxtV.scrollRangeToVisible(NSMakeRange(0, 0))
        }
        
        animator.startAnimation()
    }
    
    private func expand() {
        //檢查 collectionView 和 index 不是 nil。否則，我們將無法運行動畫。
        guard let collectionView = self.collectionView, let index = self.index else { return }
        
        //呼叫 animator.addAnimations 來開始創建動畫。
        animator.addAnimations {
            //儲存當前的框架，這是用於在折疊動畫上恢復它。
            self.initialFrame = self.frame
            
            //設置 descriptionLabel 和 closeButton 的 alpha 值使其可見。
            self.descriptionTxtV.alpha = 1
            self.closeBtn.alpha = 1
            
            //刪除圓角並為 Cell 設置新框架。Cell 將以全屏顯示。
            self.layer.cornerRadius = 0
            
            //移動相鄰的 Cell。
            self.frame = CGRect(x: collectionView.contentOffset.x, y:0 , width: collectionView.frame.width, height: collectionView.frame.height)
            
            if let leftCell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) {
                leftCell.center.x -= 50
            }
            
            if let rightCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)) {
                rightCell.center.x += 50
            }
            
            self.layoutIfNeeded()
        }
        
        //呼叫 animator.addComplete() 方法來禁止 collectionView 的交互，這可以預防使用者在 Cell 擴展時滾動它。
        //也改變了 Cell 的當前狀態，這一點很重要，因為我們只在動畫完成時作出變動。
        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                collectionView.isScrollEnabled = false
                collectionView.allowsSelection = false
            default:
                ()
            }
            //捲到開頭
            self.descriptionTxtV.scrollRangeToVisible(NSMakeRange(0, 0))
        }
        
        animator.startAnimation()
    }
    
}

extension UITextView {
    
    func increaseFontSize () {
        self.font =  UIFont(name: self.font!.fontName, size: self.font!.pointSize+1)!
    }
    
    func decreaseFontSize () {
        self.font =  UIFont(name: self.font!.fontName, size: self.font!.pointSize-1)!
    }
}

extension UIView {
    /**
     Get the view's screen shot, this function may be called from any thread of your app.
     - returns: The screen shot's image.
     */
    func genImage() -> UIImage? {
        guard frame.size.height > 0 && frame.size.width > 0 else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
