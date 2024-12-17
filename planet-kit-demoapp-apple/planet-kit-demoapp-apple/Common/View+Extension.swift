import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension View {
    @ViewBuilder func navigationItems(leading: some View = EmptyView(), trailing: some View = EmptyView()) -> some View {
        self.toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                leading
            }
            ToolbarItem(placement: .topBarTrailing) {
                trailing
            }
            #elseif os(macOS)
            ToolbarItem(placement: .navigation) {
                leading
            }
            ToolbarItem(placement: .automatic) {
                trailing
            }
            #endif
        }
    }

    func getViewName() -> String {
        String(describing: type(of: self))
    }

    #if os(iOS)
    var mainScreenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    #endif
}
