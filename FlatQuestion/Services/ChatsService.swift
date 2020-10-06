import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class ChatsService {
    private let firestore = Firestore.firestore()
    private let errorsHandler: ErrorHandler = AlertErrorMessageHandler()
    private let usersService = UsersService()
    private var lastDocumentSnapshot: DocumentSnapshot!
    private var firstFetching = true
    private var pagingIndex = 0;
    private var pageSize = 20;

    static let shared = ChatsService()

    func createListener(forUserId id: String, onChatListUpdated: @escaping () -> ()) {
        firestore.collection("chats").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(String(describing: error?.localizedDescription))")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    guard let chat = try? diff.document.data(as: Chat.self),
                        let memberIds = chat.memberIds else { return }
                    if memberIds.contains(id) {
                        onChatListUpdated()
                    }
                }
            }
        }
    }

    func createListener(forChatId id: String, onNewMessageAdded: @escaping (Message) -> ()) {
        firestore.collection("chat_\(id)").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(String(describing: error?.localizedDescription))")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    guard let message = try? diff.document.data(as: Message.self) else { return }
                    if message.senderId != UserSettings.appUser!.id! {
                        onNewMessageAdded(message)
                    }
                }
//TODO            This functionality will be in later versions of the app:
//                if (diff.type == .modified) {
//                    print("Modified city: \(diff.document.data())")
//                }
//                if (diff.type == .removed) {
//                    print("Removed city: \(diff.document.data())")
//                }
            }
        }
    }

    func createListener(forChatId id: String, onChatInfoUpdated: @escaping (Chat) -> ()) {
        firestore.collection("chat_\(id)").addSnapshotListener { querySnapshot, error in
            self.firestore.collection("chat_\(id)")
                .whereField("isRead", isEqualTo: false)
                .getDocuments { [weak self] (snapshot, error) in
                    var messages: [Message]? = [Message]()
                    if error != nil {
                        self?.errorsHandler.handle(error!.localizedDescription)
                    } else {
                        guard let documents = snapshot?.documents else { return }
                        for document in documents {
                            guard let message = try? document.data(as: Message.self) else {
                                self?.errorsHandler.handle("Error has been occured while getting a message")
                                break
                            }

                            messages?.append(message)
                        }
                    }
                    messages = messages?.sorted { $0.sentDate < $1.sentDate }
                    if let lastMessage = messages?.last {
                        onChatInfoUpdated(
                            Chat(chatId: id,
                                 lastSenderId: lastMessage.senderId,
                                 lastMessage: lastMessage.text,
                                 lastMessageSentTime: lastMessage.sentDate,
                                 unreadMessagesCount: messages?.count))
                    }
            }
        }
    }

    func getChat(byMemberIds memberIds: [String?]?) -> Chat? {
        var chat: Chat?
        let semaphore = DispatchSemaphore(value: 0)
        firestore.collection("chats")
            .whereField("memberIds", isEqualTo: memberIds as Any)
            .getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    self?.errorsHandler.handle(error!.localizedDescription)
                } else if let document = snapshot?.documents.first {
                    chat = try? document.data(as: Chat.self)
                }
                
                semaphore.signal()
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return chat
    }

    func createChat(_ chat: Chat) -> Bool {
        let success = try? firestore.collection("chats").addDocument(from: chat)
        return success != nil
    }

    func getChats(forUserId id: String) -> [Chat] {
        let operationQueue = OperationQueue()
        let chats = getChatsRawData(forUserId: id)
        for index in 0..<chats.count {
            operationQueue.addOperation(BlockOperation {
                let interlocutor = chats[index].memberIds!
                    .filter { $0 != id }
                    .map { (self.usersService.getUser(byId: $0))! }
                    .first


                if let unreadMessages = self.getUnreadMessages(forChatId: chats[index].chatId!),
                    let lastMessage = self.getLastMessage(forChatId: chats[index].chatId!) {
                    chats[index].lastMessage = lastMessage.text
                    chats[index].lastMessageSentTime = lastMessage.sentDate
                    chats[index].lastSenderId = lastMessage.senderId
                    chats[index].unreadMessagesCount = unreadMessages.count
                }

                chats[index].interlocutor = interlocutor
                chats[index].interlocuterAvatarUrl = interlocutor?.avatarUrl ?? Constants.defaultAvatarUrl
                chats[index].interlocutorFullName = interlocutor?.fullName
            })
        }

        operationQueue.waitUntilAllOperationsAreFinished()
        return chats
    }

    func getMessagesWithPaging(forChatId id: String) -> (loadMoreAvailable: Bool, messages: [Message]) {
        let collection = firestore.collection("chat_\(id)")
        var query: Query

        if lastDocumentSnapshot != nil {
            query = collection
                .order(by: "sentDate", descending: true)
                .limit(to: pageSize)
                .start(afterDocument: lastDocumentSnapshot)
        } else {
            query = collection
                .order(by: "sentDate", descending: true)
                .limit(to: pageSize)
        }

        let messages = fetchMesssges(query)

        return (loadMoreAvailable: firstFetching || lastDocumentSnapshot != nil, messages: messages)
    }

    func addMessage(message: Message, chatId: String) -> Bool {
        let success = try? firestore.collection("chat_\(chatId)").addDocument(from: message)
        return success != nil
    }

    func markMessagesAsRead(forChatId id: String) {
        firestore.collection("chat_\(id)")
            .whereField("isRead", isEqualTo: false)
            .getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    self?.errorsHandler.handle(error!.localizedDescription)
                } else {
                    let operationQueue = OperationQueue()
                    snapshot?.documents.forEach { (document) in
                        operationQueue.addOperation(BlockOperation {
                            document.reference.updateData(["isRead": true])
                        })
                    }

                    operationQueue.waitUntilAllOperationsAreFinished()
                }
        }
    }

    private func fetchMesssges(_ query: Query) -> [Message] {
        var messages: [Message]? = [Message]()
        let semaphore = DispatchSemaphore(value: 0)
        query.getDocuments { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.errorsHandler.handle(error!.localizedDescription)
            } else {
                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    guard let message = try? document.data(as: Message.self) else {
                        strongSelf.errorsHandler.handle("Error has been occured while getting a message")
                        break
                    }

                    messages?.append(message)
                }

                strongSelf.lastDocumentSnapshot = documents.last
            }

            strongSelf.firstFetching = false
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
        return messages ?? []
    }

    private func getChatsRawData(forUserId id: String) -> [Chat] {
        var chats: [Chat]? = [Chat]()
        let semaphore = DispatchSemaphore(value: 0)

        firestore.collection("chats")
            .whereField("memberIds", arrayContains: id)
            .getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    self?.errorsHandler.handle(error!.localizedDescription)
                } else {
                    guard let documents = snapshot?.documents else { return }
                    for document in documents {
                        guard let chat = try? document.data(as: Chat.self) else {
                            self?.errorsHandler.handle("Error has been occured while getting a chats")
                            break
                        }

                        chats?.append(chat)
                    }
                }
                semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
        return chats ?? []
    }

    private func getUnreadMessages(forChatId id: String) -> [Message]? {
        var messages: [Message]? = [Message]()
        let semaphore = DispatchSemaphore(value: 0)
        firestore.collection("chat_\(id)")
            .whereField("isRead", isEqualTo: false)
            .getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    self?.errorsHandler.handle(error!.localizedDescription)
                } else {
                    guard let documents = snapshot?.documents else { return }
                    for document in documents {
                        guard let message = try? document.data(as: Message.self) else {
                            self?.errorsHandler.handle("Error has been occured while getting a message")
                            break
                        }

                        messages?.append(message)
                    }
                }
                semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
        return messages?.sorted { $0.sentDate < $1.sentDate }
    }

    private func getLastMessage(forChatId id: String) -> Message? {
        var lastMessage: Message?
        let semaphore = DispatchSemaphore(value: 0)
        firestore.collection("chat_\(id)")
            .order(by: "sentDate", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] (snapshot, error) in
                if error != nil {
                    self?.errorsHandler.handle(error!.localizedDescription)
                } else if let document = snapshot?.documents.first,
                    let message = try? document.data(as: Message.self) {
                    lastMessage = message
                }
                semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
        return lastMessage
    }
}
