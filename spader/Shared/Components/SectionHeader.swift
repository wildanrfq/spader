//
//  SectionHeader.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct SectionHeader: View {
    var title: String
    
    init(_ title: String) { 
        self.title = title 
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
    }
}