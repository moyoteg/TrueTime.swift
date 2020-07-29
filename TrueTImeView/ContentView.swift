//
//  ContentView.swift
//  TrueTimeView
//
//  Created by Moi Gutierrez on 7/28/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TrueTimeView()
        .environmentObject(TrueTimeView.ViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
