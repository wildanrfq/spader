//
//  SectionFooter.swift
//  spader
//
//  Created by Wildan Rifqi on 31/10/25.
//


import SwiftUI

struct SectionFooter: View {
    var text: String
    
    init(_ text: String) { 
        self.text = text 
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}