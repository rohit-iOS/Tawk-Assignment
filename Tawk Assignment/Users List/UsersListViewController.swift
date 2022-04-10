//
//  UsersListViewController.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import UIKit

/// View class to show users list
final class UsersListViewController: UIViewController {
    
    ///IBOutlets
    @IBOutlet weak var usersListCollectionView: UICollectionView!
    @IBOutlet weak var loadMoreViewHeightConstraint: NSLayoutConstraint!
    
    ///TypeAlias for Diffable Data Source
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, UserEntity>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UserEntity>
    
    ///Properties
    private var viewModel =  UsersListViewModel()
    private lazy var dataSource = createDiffableDataSource()
    private var isLoading = false {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.loadMoreViewHeightConstraint.constant = newValue ? 50 : 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        getUsersListData()
    }
    
    /// Method to setup CollectionView
    private func setUpCollectionView() {
        
        //Register User collection view cell
        usersListCollectionView.register(UINib(nibName: Constants.Identifiers.userCollactionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.userCollactionViewCell)
        
        usersListCollectionView.collectionViewLayout = generateCopositeLayout()
    }
    
    func updateUI() {
        usersListCollectionView.reloadData()
    }
    
    func getUsersListData() {
        //Fetch products list
        viewModel.getUsersListData {
            
            DispatchQueue.main.async { [weak self] in
                self?.applySnapshot()
                self?.isLoading = false
            }
        } failure: { errorString in
            let errorMessageAlert = UIAlertController(title: "Got error", message: errorString, preferredStyle: .alert)
            errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(errorMessageAlert, animated: true, completion: nil)
        }
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

// MARK: - UICollectionViewDelegate methods
extension UsersListViewController: UICollectionViewDelegate {
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            DispatchQueue.global().async { [weak self] in
                self?.getUsersListData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == (self.viewModel.userListDataSource?.count ?? 0) - 2 && !self.isLoading {
            loadMoreData()
        }
    }
}
