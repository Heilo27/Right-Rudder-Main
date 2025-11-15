//
//  iPadPresentationHelper.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

extension View {
    /// Applies iPad-optimized sheet presentation with proper detents and sizing
    func iPadSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    /// Applies iPad-optimized sheet presentation for full-screen content
    func iPadFullScreenSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    /// Applies iPad-optimized list styling
    func iPadListStyle() -> some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return AnyView(self.listStyle(.insetGrouped))
        } else {
            return AnyView(self.listStyle(.plain))
        }
        #else
        return AnyView(self)
        #endif
    }
    
    /// Applies iPad-optimized navigation view
    func iPadNavigationView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return AnyView(
                    NavigationStack {
                        content()
                    }
                )
            } else {
                return AnyView(
                    NavigationStack {
                        content()
                    }
                )
            }
        } else {
            return AnyView(
                NavigationView {
                    content()
                }
            )
        }
        #else
        return AnyView(
            NavigationView {
                content()
            }
        )
        #endif
    }
    
    /// Applies iPad-optimized frame constraints
    func iPadFrame(maxWidth: CGFloat? = nil) -> some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let width = maxWidth ?? 600
            return AnyView(self.frame(maxWidth: width))
        } else {
            return AnyView(self)
        }
        #else
        return AnyView(self)
        #endif
    }
}

#if os(iOS)
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
#endif

