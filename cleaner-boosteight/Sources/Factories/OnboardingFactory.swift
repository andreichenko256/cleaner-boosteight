import Foundation

enum OnboardingFactory {
    static func make() -> [OnboardingPageModel] {
        return [
            .init(
                title: "Clean your Storage",
                description: "Pick the best & delete the rest",
                image: .test),
            .init(
                title: "Detect Similar Photos",
                description: "Clean similar photos & videos, save your storage\nspace on your phone.",
                image: .test),
            .init(
                title: "Video Compressor",
                description: "Find large videos or media files and compress\nthem to free up storage space",
                image: .test),
        ]
    }
}

protocol OnboardingFactoryProtocol {
    func make() -> [OnboardingPageModel]
}

