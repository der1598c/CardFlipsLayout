//
//  ViewController.swift
//  CardFlipsLayout
//
//  Created by der1598c on 08/19/2019.
//  Copyright (c) 2019 der1598c. All rights reserved.
//

import UIKit
import CardFlipsLayout

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    fileprivate var items: [Items] {
        let p1 = Items(name: "Qixingtan", image: "Qixingtan", description: "Qixing Lake (七星潭) is located in Beipu Village, Xincheng Township, in the northeast of Hualien City. Visitors can get there via Meilun Industrial Park by following the signs in front of the National Hualien University of Education. The beach there has an elegant arch shape. The seawater there is clean and blue. The black stones there are crystal. From here visitors can see the great green mountains afar and the twisting highways.")
        
        let p2 = Items(name: "Taroko", image: "Taroko", description: "When Taroko National Park (太魯閣國家公園) was established on November 28, l986, it was of special significance for the environmental protection movement in Taiwan: it showed that both the public and the government agencies had realized that against the background of the nation's four decades of extraordinary economic success, serious damage was being done to its natural resources. According to the National Park Act of the Republic of China (passed in l972), parks are established to protect the natural scenery, historic relics and wildlife; to conserve natural resources; and to facilitate scientific research and promote environmental education.")
        
        let p3 = Items(name: "Xinliao", image: "Xinliao", description: "Xinliao Waterfall (新寮瀑布) is a great, swimmable waterfall in Yilan, Dongshan Township (宜蘭縣冬山鄉). The start of the trail is at the Dongshan Forest Police Station. There are bathrooms, vendors, and ample parking. It's free, but you have to register on your way in. The path is well made, and only an 850 meter hike to a large viewing platform in front of the waterfall.")
        
        return [p1, p2, p3, p2, p1, p3]
    }
    
    @IBOutlet weak var overviewView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overviewView.collectionViewLayout = FlowLayout(itemSize: CollectionViewCell.cellSize);
        overviewView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let bundle = Bundle(for: CollectionViewCell.self)
        let nib = UINib(nibName: "CollectionViewCell", bundle: bundle)
        overviewView.register(nib, forCellWithReuseIdentifier:CollectionViewCell.identifier)
    }
    
    func overviewView(_ overviewView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = overviewView.cellForItem(at: indexPath)! as! CollectionViewCell
        selectedCell.toggle()
    }
    
}

// MARK: UICollectionViewDataSource
extension ViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = overviewView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.configure(with: items[indexPath.item], collectionView: overviewView, index: indexPath.row)
        cell.setCornerRadius(radius: 6)
        return cell
    }
}
