//
//  AppstoreView.swift
//  Ksign
//
//  Created by Nagata Asami on 3/8/25.
//

import SwiftUI
import CoreData
import AltSourceKit

struct AppstoreView: View {
	@StateObject private var _viewModel = SourcesViewModel.shared
	
	@FetchRequest(
		entity: AltSource.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \AltSource.name, ascending: true)],
		animation: .snappy
	) private var _sources: FetchedResults<AltSource>
	
	var body: some View {
		NavigationStack {
            SourceAppsView(fromAppStore: true, object: Array(_sources), viewModel: _viewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            NotificationCenter.default.post(name: NSNotification.Name("lemonsign.openSettings"), object: nil)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color(hex: "FFD60A"))
                        }
                    }
                }
		}
		.task(id: Array(_sources)) {
			await _viewModel.fetchSources(_sources)
		}
	}
}
