# CardFlipsLayout

[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)
[![Version](https://img.shields.io/cocoapods/v/CardFlipsLayout.svg?style=flat)](https://cocoapods.org/pods/CardFlipsLayout)
[![License](https://img.shields.io/cocoapods/l/CardFlipsLayout.svg?style=flat)](https://cocoapods.org/pods/CardFlipsLayout)
[![Platform](https://img.shields.io/cocoapods/p/CardFlipsLayout.svg?style=flat)](https://cocoapods.org/pods/CardFlipsLayout)

## Preview

A simple animated card flips Lib.
Base on UICollectionView, UICollectionViewCell.
Use UIViewPropertyAnimator : Making advanced animations.

![](https://github.com/der1598c/CardFlipsLayout/blob/master/demo.gif)

## Example

Includes sample iOS app.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10 and later. (iPhone)

Swift 4.2

## Installation

### CocoaPods

CardFlipsLayout is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CardFlipsLayout'
```

### Carthage

Currently not available.

## How to Use

Step 1.

```swift
@IBOutlet weak var overviewView: UICollectionView!
```
Care your dataSource, delegate.

Step 2.

```swift
fileprivate var items: [Items] {
    let p1 = Items(name: "name1", image: "photo1", description: "Description Text.")

    let p2 = Items(name: "name2", image: "photo1", description: "Description Text.")

    let p3 = Items(name: "name3", image: "photo1", description: "Description Text.")

    return [p1, p2, p3, p2, p1, p3]
}
```

Step 3.

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    overviewView.collectionViewLayout = FlowLayout(itemSize: CollectionViewCell.cellSize);
    overviewView.decelerationRate = UIScrollViewDecelerationRateFast

    let bundle = Bundle(for: CollectionViewCell.self)
    let nib = UINib(nibName: "CollectionViewCell", bundle: bundle)
    overviewView.register(nib, forCellWithReuseIdentifier:CollectionViewCell.identifier)
}
```

Step 4.

```swift
func overviewView(_ overviewView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedCell = overviewView.cellForItem(at: indexPath)! as! CollectionViewCell
    selectedCell.toggle()
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//Require
    let cell = overviewView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
    cell.configure(with: items[indexPath.item], collectionView: overviewView, index: indexPath.row)

//Custom
    cell.setCornerRadius(radius: 6)
    cell.setCloseImage(with: "p_error") //default: non, but button's title is "⊠".
    cell.setAnimationType(type: .springs_Ani) // default: .normal_Ani
    
    return cell
}
```

## Author

der1598c

## License

CardFlipsLayout is available under the MIT license. See the LICENSE file for more info.
