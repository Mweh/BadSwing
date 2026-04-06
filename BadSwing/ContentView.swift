//
//  ContentView.swift
//  BadSwing
//
//  Created by Muhammad Fahmi on 06/04/26.
//

import SwiftUI
import UIKit

// MARK: - UIViewControllerRepresentable bridge

struct SwingDetectionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SwingDetectionViewController {
        SwingDetectionViewController()
    }

    func updateUIViewController(_ uiViewController: SwingDetectionViewController, context: Context) {}
}

// MARK: - Root view

struct ContentView: View {
    var body: some View {
        SwingDetectionView()
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
