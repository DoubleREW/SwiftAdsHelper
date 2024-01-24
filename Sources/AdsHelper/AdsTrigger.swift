//
//  AdsTrigger.swift
//
//
//  Created by Fausto Ristagno on 15/01/24.
//

import Foundation
import SwiftUI

public enum AdsDisplayOrder {
    case beforeAction
    case afterAction

    public static var defaultOrder: Self {
        AdsDisplayOrder.afterAction
    }
}

struct AdsTrigger {
    private let manager: AdInterstitialManager
    private let position: AdsDisplayOrder
    private let action: () async -> Void
    private let completion: (() async -> Void)?

    init(
        manager: AdInterstitialManager,
        position: AdsDisplayOrder = .defaultOrder,
        action: @escaping () async -> Void,
        completion: (() async -> Void)? = nil
    ) {
        self.manager = manager
        self.position = position
        self.action = action
        self.completion = completion
    }

    func fire() async {
        let completion = self.completion ?? {}

        if position == .beforeAction {
            if manager.trigger() {
                manager.onDismissAction = {
                    await action()
                    await completion()
                }
            } else {
                await action()
                await completion()
            }
        } else {
            await action()

            if manager.trigger() {
                manager.onDismissAction = {
                    await completion()
                }
            } else {
                await completion()
            }
        }
    }

    func callAsFunction() async {
        await fire()
    }
}
