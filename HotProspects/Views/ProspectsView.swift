//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Hari krishna on 17/05/23.
//

import SwiftUI
import CodeScanner
import UserNotifications


enum Filter {
    case none
    case contacted
    case uncontacted
}

struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    @State var filter: Filter
    @State private var isScanning = false
    var title: String {
        switch filter {
        case .none:
            return "All"
        case .contacted:
            return "Contacted"
        case .uncontacted:
            return "Uncontacted"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter {$0.isContacted}
        case .uncontacted:
            return prospects.people.filter {!$0.isContacted}
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredProspects) { prospect in
                        VStack(alignment: .leading) {
                            Text("\(prospect.name)")
                                .font(.headline)
                            Text("\(prospect.email)")
                                .foregroundColor(.secondary)
                        }
                        .swipeActions {
                            if prospect.isContacted {
                                Button {
                                    prospects.toggle(prospect: prospect)
                                } label: {
                                    Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                                }
                                .tint(Color.blue)
                                
                            } else {
                                Button {
                                    prospects.toggle(prospect: prospect)
                                } label: {
                                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                                }
                                .tint(Color.green)
                                
                                Button {
                                    getNotification(for: prospect)
                                } label: {
                                    Label("Remind Me", systemImage: "bell")
                                }
                                .tint(.orange)

                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button {
                    isScanning = true
                } label: {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            }
            .sheet(isPresented: $isScanning) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Hari \n harikrishnakesineni@gmail.com") { result in
                    scanQr(result: result)
                }.presentationDetents([.medium])
                }
        }
    }
    
    func scanQr(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let str):
            let details = str.string.components(separatedBy: "\n")
            guard details.count == 2 else {
                return
            }
            let people = Prospect()
            people.name = details[0]
            people.email = details[1]
            prospects.add(people)
        case .failure(let error):
            print("\(error.localizedDescription)")
        }
    }
    
    func getNotification(for prospect: Prospect) {
        
        let center = UNUserNotificationCenter.current()
        
        let notifcation = {
            let content = UNMutableNotificationContent()
            content.title = "\(prospect.name)"
            content.subtitle = "\(prospect.email)"
            content.sound = .default
            
            var time = DateComponents()
            time.hour = 9
            
            //        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                notifcation()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        notifcation()
                    } else {
                        print("Authorization Failed: \(error?.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
