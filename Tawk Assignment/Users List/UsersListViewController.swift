//
//  UsersListViewController.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import UIKit

/// View class to show users list
final class UsersListViewController: UIViewController {

    ///Private Properties
    private var viewModel =  UsersListViewModel()
    private lazy var dataSource = createDiffableDataSource()

    ///TypeAlias for Diffable Data Source
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, User>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, User>
    
    ///IBOutlets
    @IBOutlet weak var usersListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionView()
        getUsersListData()
    }
    
    /// Method to setup CollectionView
    private func setUpCollectionView() {
        usersListCollectionView.register(UINib(nibName: Constants.Identifiers.userCollactionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.userCollactionViewCell)
        usersListCollectionView.collectionViewLayout = generateCopositeLayout()

    }
    
    func updateUI() {
        usersListCollectionView.reloadData()
    }
    
    func getUsersListData() {
        //Fetch products list
        viewModel.getUsersListData(success: {
            
            DispatchQueue.main.async { [weak self] in
                self?.applySnapshot()
            }
        }, failure: { errorString in
            let errorMessageAlert = UIAlertController(title: "Got error", message: errorString, preferredStyle: .alert)
            errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(errorMessageAlert, animated: true, completion: nil)
        })
    }
    
    /// Method to create diffable data source for CollectionView
    /// - Returns: diffableDataSource
    private func createDiffableDataSource() -> DiffableDataSource {
        let dataSource = DiffableDataSource(
            collectionView: usersListCollectionView,
            cellProvider: { collectionView, indexPath, serviceItem ->
                UICollectionViewCell? in
                
                let userCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Constants.Identifiers.userCollactionViewCell,
                    for: indexPath) as? UserCollectionViewCell
                
                if let userData = self.viewModel.userListDataSource?[indexPath.row] {
                    userCell?.configureUserCell(viewModel: userData)
                }
                return userCell
            })
        return dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.viewModel.userListDataSource ?? [])
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
