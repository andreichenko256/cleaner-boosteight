import Foundation

protocol OnboardingServiceProtocol {
    func hasCompletedOnboarding() -> Bool
    func markOnboardingAsCompleted()
    func resetOnboarding()
}

final class OnboardingService: OnboardingServiceProtocol {
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func hasCompletedOnboarding() -> Bool {
        return userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
    }
    
    func markOnboardingAsCompleted() {
        userDefaults.set(true, forKey: Keys.hasCompletedOnboarding)
    }
    
    func resetOnboarding() {
        userDefaults.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}
