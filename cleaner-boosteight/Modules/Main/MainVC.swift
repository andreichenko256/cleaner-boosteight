import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    private let diskInfoService: DiskInfoServiceProtocol
    
    private var mainView: MainView {
        return view as! MainView
    }
    
    init(diskInfoService: DiskInfoServiceProtocol = DiskInfoService()) {
        self.diskInfoService = diskInfoService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDiskInfo()
    }
    
    override func loadView() {
        view = MainView()
    }
}

private extension MainViewController {
    func loadDiskInfo() {
        do {
            let diskInfo = try diskInfoService.getDiskInfo()
            
            let usedSpaceFormatted = diskInfo.usedSpace.formattedBytesRounded(to: 1)
            let totalSpaceFormatted = "of \(diskInfo.totalSpace.formattedBytesRounded(to: 1))"
            
            mainView.valueStorageLabel.setTexts(
                semibold: usedSpaceFormatted,
                regular: totalSpaceFormatted,
                fontSize: 16,
                color: Colors.primaryWhite
            )
            
            mainView.circularProgressView.setProgress(
                diskInfo.usagePercentage,
                animated: true,
                duration: 1.5
            )
        } catch {
            print("Failed to load disk info: \(error)")
            mainView.circularProgressView.setProgress(0, animated: false)
        }
    }
}
