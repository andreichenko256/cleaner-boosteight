import Foundation
import Combine
import AVFoundation
import Photos

protocol SelectVideoQualityViewModelProtocol: AnyObject {
    var player: AVPlayer? { get }
    var selectedQuality: VideoQuality { get }
    var isLoadingVideo: Bool { get }
    var errorMessage: String? { get }
    
    var playerPublisher: AnyPublisher<AVPlayer?, Never> { get }
    var selectedQualityPublisher: AnyPublisher<VideoQuality, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    func loadVideo()
    func selectQuality(_ quality: VideoQuality)
    func cleanup()
}

final class SelectVideoQualityViewModel: SelectVideoQualityViewModelProtocol {
    
    @Published private(set) var player: AVPlayer?
    @Published private(set) var selectedQuality: VideoQuality = .medium
    @Published private(set) var isLoadingVideo: Bool = false
    @Published private(set) var errorMessage: String?
    
    var playerPublisher: AnyPublisher<AVPlayer?, Never> {
        $player.eraseToAnyPublisher()
    }
    
    var selectedQualityPublisher: AnyPublisher<VideoQuality, Never> {
        $selectedQuality.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoadingVideo.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    
    private let videoModel: VideoModel
    private var cancellables = Set<AnyCancellable>()
    
    init(videoModel: VideoModel) {
        self.videoModel = videoModel
    }

    func loadVideo() {
        guard !isLoadingVideo else { return }
        
        isLoadingVideo = true
        errorMessage = nil
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestPlayerItem(
            forVideo: videoModel.asset,
            options: options
        ) { [weak self] playerItem, info in
            DispatchQueue.main.async {
                self?.handleVideoLoaded(playerItem: playerItem, info: info)
            }
        }
    }
    
    func selectQuality(_ quality: VideoQuality) {
        guard selectedQuality != quality else { return }
        selectedQuality = quality
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        cancellables.removeAll()
    }
    
    private func handleVideoLoaded(playerItem: AVPlayerItem?, info: [AnyHashable: Any]?) {
        isLoadingVideo = false
        
        if let error = info?[PHImageErrorKey] as? Error {
            errorMessage = "Failed to load video: \(error.localizedDescription)"
            return
        }
        
        guard let playerItem = playerItem else {
            errorMessage = "Failed to load video"
            return
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
}
