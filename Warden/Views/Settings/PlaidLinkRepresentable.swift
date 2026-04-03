//
//  PlaidLinkRepresentable.swift
//  Warden
//

import SwiftUI
import LinkKit

/// Wraps Plaid's LinkKit Handler in a UIViewControllerRepresentable.
/// Presents the Plaid Link sheet as soon as the host VC appears.
struct PlaidLinkRepresentable: UIViewControllerRepresentable {

    let linkToken: String
    let onSuccess: (String, String) -> Void   // (publicToken, institutionName)
    let onExit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(linkToken: linkToken, onSuccess: onSuccess, onExit: onExit)
    }

    func makeUIViewController(context: Context) -> ContainerViewController {
        let vc = ContainerViewController()
        vc.coordinator = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ContainerViewController, context: Context) {}

    // MARK: - Container VC

    /// Transparent host that opens the Plaid Link sheet on first appearance.
    final class ContainerViewController: UIViewController {
        var coordinator: Coordinator?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            coordinator?.openLink(from: self)
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        private var handler: Handler?
        private let linkToken: String
        private let onSuccess: (String, String) -> Void
        private let onExit: () -> Void
        private var didOpen = false

        init(
            linkToken: String,
            onSuccess: @escaping (String, String) -> Void,
            onExit: @escaping () -> Void
        ) {
            self.linkToken = linkToken
            self.onSuccess = onSuccess
            self.onExit = onExit
        }

        func openLink(from vc: UIViewController) {
            guard !didOpen else { return }
            didOpen = true

            var configuration = LinkTokenConfiguration(token: linkToken) { [weak self] success in
                let name = success.metadata.institution.name
                self?.onSuccess(success.publicToken, name)
            }
            configuration.onExit = { [weak self] linkExit in
                self?.onExit()
            }

            switch Plaid.create(configuration) {
            case .success(let h):
                handler = h
                h.open(presentUsing: PresentationMethod.custom({ [weak vc] linkVC in
                    vc?.present(linkVC, animated: true)
                }))
            case .failure(let error):
                print("[PlaidLinkRepresentable] Handler creation failed: \(error)")
                onExit()
            }
        }
    }
}
