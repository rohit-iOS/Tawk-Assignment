//
//  CoreDataManager.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 09/04/2022.
//

import Foundation
import CoreData

class CoreDataManager {
    
    // MARK: Core Data
    
    /// A shared CoreDataManager for use within the main app bundle.
    static let shared = CoreDataManager()
    private var taskReadContext: NSManagedObjectContext?
    
    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?
    
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
        
        // Observe Core Data remote change notifications on the User where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            print("Received a persistent store remote change notification.")
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func fetchPersistentHistory() async {
        fetchPersistentHistoryTransactionsAndChanges()
    }
    
    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        /// - Tag: persistentContainer
        let container = NSPersistentContainer(name: "Tawk_Assignment")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // This refreshe UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    /// Fetches the Users listing from the remote server, and imports it into Core Data.
    func insertUserData(_ users:[UserEntity]) async throws {
        // Import the GeoJSON into Core Data.
        print("Start importing data to the store...")
        try await importUserList(from: users)
        print("Finished importing data.")
        
    }
    
    func fetchUserNotes(userName: String,
                        success: @escaping (String) -> Void,
                         failure: @escaping (String) -> Void) {
        
        let fetchRequest = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username = %@", userName)
        // Get a reference to a NSManagedObjectContext
        let context = container.viewContext

        do {
            let fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count != 0{

                let userObject = fetchResults.first
                success(userObject?.value(forKey: "note") as! String)
            }
                
        } catch {
            debugPrint("We got a failure while saving note. The error we got was: \(error.localizedDescription)")
            failure(error.localizedDescription)
        }
    }

    func updateUserNotes(note: String,
                         userName: String,
                         success: @escaping () -> Void,
                         failure: @escaping (String) -> Void) {
        
        let fetchRequest = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username = %@", userName)
        // Get a reference to a NSManagedObjectContext
        let context = container.viewContext

        do {
            let fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count != 0{

                let userObject = fetchResults.first
                userObject?.setValue(note, forKey: "note")

                try context.save()
                success()
            }
                
        } catch {
            debugPrint("We got a failure while saving note. The error we got was: \(error.localizedDescription)")
            failure(error.localizedDescription)
        }
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    private func importUserList(from userList: [UserEntity]) async throws {
        guard !userList.isEmpty else { return }
        
        let taskWriteContext = newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskWriteContext.name = "importContext"
        taskWriteContext.transactionAuthor = "importUsers"
        
        taskWriteContext.perform({
            do {
                // Execute the batch insert.
                /// - Tag: batchInsertRequest
                let batchInsertRequest = self.newBatchInsertRequest(with: userList)
                if let fetchResult = try? taskWriteContext.execute(batchInsertRequest),
                   let batchInsertResult = fetchResult as? NSBatchInsertResult,
                   let success = batchInsertResult.result as? Bool, success {
                    return
                }
                print("Failed to execute batch insert request.")
            }
        })
        print("Successfully inserted data.")
    }
    
    private func newBatchInsertRequest(with userList: [UserEntity]) -> NSBatchInsertRequest {
        var index = 0
        let total = userList.count
        
        // Provide one dictionary at a time when the closure is called.
        if #available(iOS 14.0, *) {
            let batchInsertRequest = NSBatchInsertRequest(entity: UserEntity.entity(), dictionaryHandler: { dictionary in
                guard index < total else { return true }
                dictionary.addEntries(from: userList[index].dictionaryValue)
                index += 1
                return false
            })
            return batchInsertRequest
        } else {
            // Fallback on earlier versions
        }
        
        return NSBatchInsertRequest()
    }
    
    func fetchAllEntitiesFor(pageNumber: Int) throws -> [UserEntity] {
        let fetchRequest = UserEntity.fetchRequest()
        fetchRequest.fetchBatchSize = 30
        
        // Get a reference to a NSManagedObjectContext
        let context = container.viewContext

        // Fetch all objects of one Entity type
        let objects = try context.fetch(fetchRequest)
        
        if objects.count > 0 {
            return objects
        } else {
            throw UserListError.missingData
        }
    }
    
    /// Synchronously deletes given records in the Core Data store with the specified object IDs.
    func deleteUsers(identifiedBy objectIDs: [NSManagedObjectID]) {
        let viewContext = container.viewContext
        print("Start deleting data from the store...")
        
        viewContext.perform {
            objectIDs.forEach { objectID in
                let user = viewContext.object(with: objectID)
                viewContext.delete(user)
            }
        }
        
        print("Successfully deleted data.")
    }
    
    private func fetchPersistentHistoryTransactionsAndChanges() {
        if taskReadContext == nil {
            taskReadContext = newTaskContext()
        }
        taskReadContext?.name = "persistentHistoryContext"
        print("Start fetching persistent history changes from the store...")
        
        taskReadContext?.perform({
            do {
                // Execute the persistent history change since the last transaction.
                /// - Tag: fetchHistory
                let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
                let historyResult = try? self.taskReadContext?.execute(changeRequest) as? NSPersistentHistoryResult
                if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
                   !history.isEmpty {
                    self.mergePersistentHistoryChanges(from: history)
                    return
                }
                
                print("No persistent history transactions found.")
            }
        })
        print("Finished merging history changes.")
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        print("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
    
    // MARK: User Details
    
    func insertUserDetails(userName: String,
                         success: @escaping () -> Void,
                         failure: @escaping (String) -> Void) {
        guard !userName.isEmpty else { return }
        
        let taskWriteContext = newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskWriteContext.name = "importContext"
        taskWriteContext.transactionAuthor = "importUserDetails"
        
        taskWriteContext.perform({
            do {
                // Execute the batch insert.
                let entity = NSEntityDescription.entity(forEntityName: "UsersDetailEntity", in: taskWriteContext)
                let record = NSManagedObject(entity: entity, insertInto: taskWriteContext)
                record.setValue(<#T##Any?#>, forKey: <#T##String#>)


            }
        })
        print("Successfully inserted data.")
    }
    
    func fetchUserDetailsEntity(userName: String) throws -> UsersDetailEntity {
        let fetchRequest = UsersDetailEntity.fetchRequest()
        
        // Get a reference to a NSManagedObjectContext
        let context = container.viewContext

        // Fetch all objects of one Entity type
        let objects = try context.fetch(fetchRequest)
        
        if objects.count > 0 {
            if let userDetails = objects.first {
                return userDetails
            } else {
                throw UserListError.missingData
            }
        } else {
            throw UserListError.missingData
        }
    }
}
