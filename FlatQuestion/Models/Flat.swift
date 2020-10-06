import Foundation

struct Flat {
    var title: String
    var address: String
    var numberOfPersons: Int
    var dateToCome: String
    var arrayWithDescription: [FlatDescription]
}

struct FlatDescription {
    var name: String
    var description: String
}
