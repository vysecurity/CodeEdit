//
//  ExtensionInstallationViewModel.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 8.04.22.
//

import Foundation
import Combine
import ExtensionsStore

class ExtensionInstallationViewModel: ObservableObject {
    var plugin: Plugin

    init(plugin: Plugin) {
        self.plugin = plugin
    }

    @Published var release: PluginRelease?
    @Published var releases = [PluginRelease]()

    // Tells if all records have been loaded. (Used to hide/show activity spinner)
    var listFull = false
    // Tracks last page loaded. Used to load next page (current + 1)
    var currentPage = 1
    // Limit of records per page. (Only if backend supports, it usually does)
    let perPage = 10

    private var cancellable: AnyCancellable?

    func fetch() {
        cancellable = ExtensionsStoreAPI.pluginReleases(id: plugin.id, page: currentPage)
            .tryMap { $0.items }
            .catch { _ in Just(self.releases) }
            .sink { [weak self] in
                self?.currentPage += 1
                self?.releases.append(contentsOf: $0)
                // If count of data received is less than perPage value then it is last page.
                if $0.count < self?.perPage ?? 10 {
                    self?.listFull = true
                }
        }
    }

}
