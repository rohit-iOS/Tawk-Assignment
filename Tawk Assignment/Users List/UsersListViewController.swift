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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectedUserDataDidChange(_:)),
            name: .selectedUserDataDidChange,
            object: nil)
    }
    
    /// Method to setup CollectionView
    private func setUpCollectionView() {
        
        //Register User collection view cell
        usersListCollectionView.register(UINib(nibName: Constants.Identifiers.normalCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.normalCollectionViewCell)
        
        usersListCollectionView.register(UINib(nibName: Constants.Identifiers.noteCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.noteCollectionViewCell)
        
        usersListCollectionView.register(UINib(nibName: Constants.Identifiers.invertedCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.invertedCollectionViewCell)

        usersListCollectionView.register(UINib(nibName: Constants.Identifiers.invertedNoteCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.invertedNoteCollectionViewCell)

        usersListCollectionView.collectionViewLayout = generateCopositeLayout()
    }
    
    func updateUI() {
        usersListCollectionView.reloadData()
    }
    
    /// Fetching users list data to display
    func getUsersListData() {
        //Fetch products list
        viewModel.getUsersListData {
            
            DispatchQueue.main.async { [weak self] in
                self?.applySnapshot()
                self?.isLoading = false
            }
        } failure: { [weak self] errorString in
            let errorMessageAlert = UIAlertController(title: "Got error", message: errorString, preferredStyle: .alert)
            errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(errorMessageAlert, animated: true, completion: nil)
        }
    }
    
    @objc
    /// Observer method for User data change
    /// - Parameter notification: notification
    private func selectedUserDataDidChange(_ notification: Notification) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserEntity>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.viewModel.userListDataSource ?? [])
        if #available(iOS 15.0, *) {
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            // Fallback on earlier versions
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    /// Method to create diffable data source for CollectionView
    /// - Returns: diffableDataSource
    private func createDiffableDataSource() -> DiffableDataSource {
        let dataSource = DiffableDataSource(
            collectionView: usersListCollectionView,
            cellProvider: { collectionView, indexPath, serviceItem ->
                UICollectionViewCell? in
                
                var cell = UICollectionViewCell()
                 guard let  item = self.viewModel.userListDataSource?[indexPath.row] else {
                     return UICollectionViewCell()
                 }
                    switch item.type {
                    case .Note:
                        ///To show inverted image cell
                        if ((indexPath.row + 1) % 4) == 0 {
                            if let userCell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: Constants.Identifiers.invertedNoteCollectionViewCell,
                                for: indexPath) as? InvertedNoteCollectionViewCell {
                                userCell.configureUserCell(viewModel: item)
                                cell = userCell
                            }
                        } else if let userCell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: Constants.Identifiers.noteCollectionViewCell,
                            for: indexPath) as? NoteCollectionViewCell {
                            userCell.configureUserCell(viewModel: item)
                            cell = userCell
                        }
                        
                    case .Normal:
                        ///To show inverted image cell
                        if ((indexPath.row + 1) % 4) == 0 {
                            if let userCell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: Constants.Identifiers.invertedCollectionViewCell,
                                for: indexPath) as? InvertedCollectionViewCell {
                                userCell.configureUserCell(viewModel: item)
                                cell = userCell
                            }
                        } else if let userCell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: Constants.Identifiers.normalCollectionViewCell,
                            for: indexPath) as? NormalCollectionViewCell {
                            userCell.configureUserCell(viewModel: item)
                            cell = userCell
                        }
                    }
                return cell
            })
        return dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.viewModel.userListDataSource ?? [])
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    /// Created composite layout to arranged Users cells
    private func generateCopositeLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(((self.view.bounds.width - 40)/2) * 1.50))
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/3))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)
        return compositionalLayout
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsViewController = segue.destination as? UserDetailsViewController{
            guard let selectedUser = sender as? UserEntity, let userName = selectedUser.username else { return }
            detailsViewController.userName = userName
        }
    }
}

// MARK: - UICollectionViewDelegate methods
extension UsersListViewController: UICollectionViewDelegate {
    
    /// Pagination ,ethod to load more data
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedUser = viewModel.userListDataSource?[indexPath.row] else { return }
        self.performSegue(withIdentifier: Constants.Identifiers.userDetailsViewSegue, sender: selectedUser)
    }
}
