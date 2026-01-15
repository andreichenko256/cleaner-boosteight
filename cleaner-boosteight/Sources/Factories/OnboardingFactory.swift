import Foundation

enum OnboardingFactory {
    static func make() -> [OnboardingPageModel] {
        return [
            .init(
                title: "Clean your Storage",
                description: "Pick the best & delete the rest",
                image: .onb1),
            .init(
                title: "Detect Similar Photos",
                description: "Clean similar photos & videos, save your storage\nspace on your phone.",
                image: .onb2),
            .init(
                title: "Video Compressor",
                description: "Find large videos or media files and compress\nthem to free up storage space",
                image: .onb3),
        ]
    }
}

protocol OnboardingFactoryProtocol {
    func make() -> [OnboardingPageModel]
}

