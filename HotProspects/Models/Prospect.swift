//
//  Prospect.swift
//  HotProspects
//
//  Created by Hari krishna on 17/05/23.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var email: String = ""
    fileprivate(set) var isContacted: Bool = false
}

@MainActor
class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    var savedKey = "savedKey"
    
    init() {
        people = []
        if let userData = UserDefaults.standard.data(forKey: savedKey) {
            do {
                self.people = try JSONDecoder().decode([Prospect].self, from: userData)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func save() {
        let encodedData = try? JSONEncoder().encode(people)
        UserDefaults.standard.set(encodedData, forKey: savedKey)
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
}

