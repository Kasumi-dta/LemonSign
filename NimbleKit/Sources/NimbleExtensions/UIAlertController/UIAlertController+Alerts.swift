//
//  UIAlertController+Alerts.swift
//  NimbleKit
//
//  Created by samara on 28.04.2025.
//

import UIKit.UIAlertController

extension UIAlertController {
    /// Presents an alert
    /// - Parameters:
    ///   - presenter: View where its presenting
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - actions: Alert actions
    static public func showAlertWithCancel(
        _ presenter: UIViewController = UIApplication.topViewController()!,
        _ popoverFromView: UIView? = nil,
        title: String?,
        message: String?,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction]
    ) {
        var actions = actions
        actions.append(
            UIAlertAction(title: .localized("Cancel"), style: .cancel, handler: nil)
        )
        
        showAlert(
            presenter,
            popoverFromView,
            title: title,
            message: message,
            style: style,
            actions: actions
        )
    }
	/// Presents an alert with an OK button
	/// - Parameters:
	///   - presenter: View where it is presenting
	///   - title: Alert title
	///   - message: Alert message
	///   - style: Alert controller style
	///   - isCancel: If true, sets action style to cancel and no handler
	///   - action: Closure to run when OK is tapped (ignored if isCancel is true)
	static public func showAlertWithOk(
		_ presenter: UIViewController = UIApplication.topViewController()!,
		_ popoverFromView: UIView? = nil,
		title: String?,
		message: String?,
		style: UIAlertController.Style = .alert,
		isCancel: Bool = false,
        thankYou: Bool = false,
		action: (() -> Void)? = nil
	) {
		var actions: [UIAlertAction] = []
		
		let alertAction = UIAlertAction(
            title: thankYou ? "Thank You!" : "OK",
			style: isCancel ? .cancel : .default,
			handler: { _ in
				if !isCancel {
					action?()
				}
			}
		)
		
		actions.append(alertAction)
		
		showAlert(
			presenter,
			popoverFromView,
			title: title,
			message: message,
			style: style,
			actions: actions
		)
	}
	/// Presents an alert
	/// - Parameters:
	///   - presenter: View where its presenting
	///   - title: Alert title
	///   - message: Alert message
	static public func showAlertWithRestart(
		_ presenter: UIViewController = UIApplication.topViewController()!,
		_ popoverFromView: UIView? = nil,
		title: String?,
		message: String?,
		style: UIAlertController.Style = .alert
	) {
		var actions: [UIAlertAction] = []
		actions.append(
			UIAlertAction(title: "Suspend", style: .default) { _ in
				UIApplication.shared.suspend()
			}
		)
		actions.append(
			UIAlertAction(title: "Later", style: .cancel, handler: nil)
		)
		
		showAlert(
			presenter,
			popoverFromView,
			title: title,
			message: message,
			style: style,
			actions: actions
		)
	}
	/// Presents an alert
	/// - Parameters:
	///   - presenter: View where its presenting
	///   - title: Alert title
	///   - message: Alert message
	///   - actions: Alert actions
	static public func showAlert(
		_ presenter: UIViewController = UIApplication.topViewController()!,
		_ popoverFromView: UIView? = nil,
		title: String?,
		message: String?,
		style: UIAlertController.Style = .alert,
		actions: [UIAlertAction]
	) {
		let alert = Self(title: title, message: message, preferredStyle: style)
		actions.forEach { alert.addAction($0) }
		
		if
			style == .actionSheet,
			let popover = alert.popoverPresentationController,
			let view = popoverFromView
		{
			popover.sourceView = view
			popover.sourceRect = view.bounds
			popover.permittedArrowDirections = .any
		}
		
		presenter.present(alert, animated: true)
	}

    static public func showAlertWithTextBox(
        _ presenter: UIViewController = UIApplication.topViewController()!,
        _ popoverFromView: UIView? = nil,
        title: String?,
        message: String?,
        textFieldPlaceholder: String?,
		textFieldText: String = "",
        submit: String?,	
        cancel: String?,
        style: UIAlertController.Style = .alert,
        onSubmit: @escaping (String) -> Void
    ) {
        let alert = Self(title: title, message: message, preferredStyle: style)
        alert.addTextField { textField in
            textField.placeholder = textFieldPlaceholder
            textField.text = textFieldText
        }
        let cancel = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        let submit = UIAlertAction(title: submit, style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            onSubmit(text)
        }
        alert.addAction(cancel)
        alert.addAction(submit)
        
        if
            style == .actionSheet,
            let popover = alert.popoverPresentationController,
            let view = popoverFromView
        {
            popover.sourceView = view
            popover.sourceRect = view.bounds
            popover.permittedArrowDirections = .any
        }
        presenter.present(alert, animated: true)
    }
}
