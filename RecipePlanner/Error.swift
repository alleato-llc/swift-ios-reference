import Foundation
import SwiftUI

enum RecipePlannerError: Error, LocalizedError {
    case notFound(entity: String, id: UUID)
    case invalidInput(message: String)
    case repositoryFailure(underlying: Error)
    case networkFailure(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notFound(let entity, let id):
            "Could not find \(entity) with id \(id)"
        case .invalidInput(let message):
            message
        case .repositoryFailure(let underlying):
            "Data error: \(underlying.localizedDescription)"
        case .networkFailure(let underlying):
            "Network error: \(underlying.localizedDescription)"
        }
    }
}

@Observable
@MainActor
final class ErrorPresenter {
    var currentError: RecipePlannerError?
    var isShowingError = false

    func present(_ error: Error) {
        if let recipePlannerError = error as? RecipePlannerError {
            currentError = recipePlannerError
        } else {
            currentError = .repositoryFailure(underlying: error)
        }
        isShowingError = true
    }

    func dismiss() {
        currentError = nil
        isShowingError = false
    }
}
