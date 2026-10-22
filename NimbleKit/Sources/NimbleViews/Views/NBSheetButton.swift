//
//  NBSheetButton.swift
//  NimbleKit
//
//  Created by samara on 8.05.2025.
//

import SwiftUI

public struct NBSheetButton: View {
	private var _title: String
	
	public init(title: String) {
		self._title = title
	}
	
	public var body: some View {
        if #available(iOS 26.0, *) {
            Text(_title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .foregroundColor(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
                .bold()
                .frame(height: 50)
                .glassEffect(.regular.tint(.accentColor.opacity(0.9)).interactive(), in: .rect(cornerRadius: 28))
                .padding()
        } else {
            Text(_title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .bold()
                .frame(height: 50)
                .padding()
        }
	}
}
