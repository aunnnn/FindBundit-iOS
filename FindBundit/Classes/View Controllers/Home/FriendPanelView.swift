//
//  FriendPanelView.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/18/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import SteviaLayout
import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import RealmSwift

protocol FriendPanelViewDelegate: class {
    func friendPanelViewDidSelectFriendWithUsername(username: String)
}

class FriendPanelView: UIView {
    
    class CollectionViewLayout: UICollectionViewFlowLayout {
        
        override init() {
            super.init()
            self.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
            self.minimumLineSpacing = 4
            self.minimumInteritemSpacing = 6
            self.itemSize = CGSize(width: 44, height: 44)
            self.scrollDirection = .Horizontal
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    weak var delegate: FriendPanelViewDelegate?
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewLayout())
    private let disposeBag = DisposeBag()
    private let friendsVariable = Variable<[RealmUserProfile]>([])
    
    init(friends: List<RealmUserProfile>) {
        
        super.init(frame: .zero)
        
        self.opaque = true
        self.backgroundColor = UIColor.flatWhiteColor()

        self.collectionView.then { (cllv) in
            cllv.alwaysBounceHorizontal = true
            cllv.backgroundColor = UIColor.flatWhiteColorDark()
            cllv.registerClass(UserIconCell.self, forCellWithReuseIdentifier: "Cell")
        }
        
        friends.asObservableArray().bindTo(friendsVariable).addDisposableTo(disposeBag)
        
        friendsVariable
            .asObservable()
            .bindTo(collectionView.rx_itemsWithCellIdentifier("Cell", cellType: UserIconCell.self)) { (row, element, cell) in
                if let url = element.pictureURL where !url.absoluteString.isEmpty {
                    cell.setIcon(url)
                } else {
                    cell.setUsername(element.username)
                }
                cell.isActive = element.isActive && element.latestCoordinate.isValid
            }
            .addDisposableTo(disposeBag)
        
        
        collectionView.rx_itemSelected.subscribeNext { [weak self] ind in
            
            guard let `self` = self else { return }
            
            if let cell = self.collectionView.cellForItemAtIndexPath(ind) as? UserIconCell {
                cell.animateSelected()
            }
            
            self.delegate?.friendPanelViewDidSelectFriendWithUsername(self.friendsVariable.value[ind.row].username)
            
        }.addDisposableTo(disposeBag)
    
        
        self.sv(collectionView)
        collectionView.fillContainer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
