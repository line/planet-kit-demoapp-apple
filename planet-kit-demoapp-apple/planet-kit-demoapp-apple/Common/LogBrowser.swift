import SwiftUI
import Foundation

class LogBrowserViewModel: ObservableObject {
    @Published private var basePath: URL?
    @Published private var allowExtensions: [String]?
    @Published var selectedFilePath: URL?
    @Published var items: [DropFileItem] = []
    @Published private var currentPath: URL?

    #if os(iOS)
    @Published var showShareSheet = false
    @Published var shareURL: URL?
    #endif

    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: CInt = -1
    private var navigationRouter: NavigationRouter?
    deinit {
        stopMonitoring()
    }

    func initDefaultPath() {
        guard let basePath = defaultPath else { return }
        self.basePath = basePath
        stopMonitoring()
        startMonitoring(url: basePath)
        browsePath(url: basePath)
    }

    func cancel() {
        navigationRouter?.path.removeLast()
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }

    private var defaultPath: URL? {
        if let directory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            let basePath = directory.appendingPathComponent("PlanetKit/")
            return basePath
        }
        return nil
    }

    private func startMonitoring(url: URL) {
        fileDescriptor = open(url.path, O_EVTONLY)

        guard fileDescriptor != -1 else {
            AppLog.v("Failed to open directory")
            return
        }

        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: DispatchQueue.main)

        source?.setEventHandler { [weak self] in
            self?.browsePath(url: url)
        }

        source?.setCancelHandler { [weak self] in
            if let fileDescriptor = self?.fileDescriptor {
                close(fileDescriptor)
            }
            self?.fileDescriptor = -1
            self?.source = nil
        }

        source?.resume()
    }

    private func stopMonitoring() {
        source?.cancel()
        if fileDescriptor != -1 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
    }

    func browsePath(url: URL) {
        var newItems: [DropFileItem] = []
        do {
            let entities = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.contentModificationDateKey, .isHiddenKey], options: [])
            for entity in entities {
                do {
                    let resourceValues = try entity.resourceValues(forKeys: [.isHiddenKey, .contentModificationDateKey])
                    let isHidden = resourceValues.isHidden ?? false
                    if isHidden {
                        continue
                    }

                    let attributes = try FileManager.default.attributesOfItem(atPath: entity.path)
                    let isDir = (attributes[.type] as? FileAttributeType) == .typeDirectory
                    let name = entity.lastPathComponent
                    let modDate = attributes[.modificationDate] as? Date ?? Date()

                    if let allowExtensions = allowExtensions {
                        let ext = name.split(separator: ".").last.map(String.init)
                        if !allowExtensions.contains(ext ?? "") {
                            continue
                        }
                    }

                    newItems.append(DropFileItem(name: name, isDir: isDir, modDate: modDate, url: entity))
                } catch {
                    AppLog.v("Error loading metadata for documentURL:\(entity) error:\(error)")
                    continue // Skip this file and move to the next one
                }
            }

            newItems.sort { $0.modDate > $1.modDate }
            self.items = newItems
            self.currentPath = url
        } catch {
            AppLog.v("Error browsing path: \(error)")
        }
    }

    func deleteAllFiles() {
        guard let currentPath = currentPath else { return }
        do {
            let entities = try FileManager.default.contentsOfDirectory(at: currentPath, includingPropertiesForKeys: nil, options: [])
            for entity in entities {
                try FileManager.default.removeItem(at: entity)
            }
            browsePath(url: currentPath)
        } catch {
            AppLog.v("Error deleting files: \(error)")
        }
    }

    func openFinder() {
        #if os(macOS)
        guard let currentPath = currentPath else { return }
        NSWorkspace.shared.open(currentPath)
        #else
        // iOS does not have a direct equivalent to open Finder
        // You might want to use UIDocumentPickerViewController to open the Files app
        #endif
    }

    func share(url: URL) {
        #if os(macOS)
        let picker = NSSharingServicePicker(items: [url])
        if let window = NSApplication.shared.windows.first {
            picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
        }
        #else
        shareURL = url
        showShareSheet = true
        #endif
    }
}

struct LogBrowserView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel = LogBrowserViewModel()

    var body: some View {
        VStack {
            List(viewModel.items, id: \.url) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text(formatDate(item.modDate))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        if item.isDir {
                            viewModel.browsePath(url: item.url)
                        } else {
                            viewModel.selectedFilePath = item.url
                        }
                        viewModel.share(url: item.url)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .contentShape(Rectangle())
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button(action: {
                        viewModel.cancel()
                    }) {
                        Image(systemName: "xmark")
                    }
                    Button(action: {
                        viewModel.deleteAllFiles()
                    }) {
                        Image(systemName: "trash")
                    }
                    Button(action: {
                        viewModel.openFinder()
                    }) {
                        Image(systemName: "folder")
                    }
                }
            }
        }
        .onAppear {
            viewModel.initDefaultPath()
            viewModel.setNavigationRouter(router: navigationRouter)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
        #if os(iOS)
        .sheet(isPresented: $viewModel.showShareSheet, content: {
            if let shareURL = viewModel.shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        })
        #endif
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DropFileItem: Identifiable {
    var id: URL { url }
    let name: String
    let isDir: Bool
    let modDate: Date
    let url: URL
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

struct LogBrowserViewWrapper: View {
    @StateObject private var navigationRouter = NavigationRouter()
    var body: some View {
        LogBrowserView()
            .environmentObject(navigationRouter)
    }
}
#Preview {
    LogBrowserViewWrapper()
}
