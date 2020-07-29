//
//  TrueTimeView.swift
//  TrueTimeView
//
//  Created by Moi Gutierrez on 7/28/20.
//

import SwiftUI
import TrueTime

struct TrueTimeView: View {
    
    public class ViewModel: ObservableObject {
        
        fileprivate var referenceTime: ReferenceTime?
        
        fileprivate var timer: Timer?
        
        @Published var textToShow = "[-----]"
        
        public init() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(startTimer),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(cancelTimer),
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func startTimer() {
            print("TrueTimeView: start timer called")
            timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }
        
        @objc func cancelTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        func tick() {
            if let referenceTime = referenceTime {
                let trueTime = referenceTime.now()
                textToShow = "\(trueTime)\n\n\(referenceTime)"
            }
        }
        
        func refresh() {
            TrueTimeClient.sharedInstance.fetchIfNeeded { result in
                switch result {
                case let .success(referenceTime):
                    self.referenceTime = referenceTime
                    print("ViewModel: Got network time! \(referenceTime)")
                case let .failure(error):
                    print("ViewModel: Error: \(error)")
                }
            }
        }
    }
    
    @EnvironmentObject public var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    HStack {
                        Text("\(self.viewModel.textToShow)")
                    }
                }
            }
            .navigationBarTitle(Text("True Time View"))
            .navigationBarItems(trailing:
                Button(action: {
                    self.viewModel.refresh()
                }) {
                    Text("refresh")
                }
            )
        }
        .onAppear {
            TrueTimeClient.sharedInstance.start()
            
            self.viewModel.refresh()
            self.viewModel.startTimer()
        }
        .onDisappear {
            self.viewModel.cancelTimer()
        }
    }
}
