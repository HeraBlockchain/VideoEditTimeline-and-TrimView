import UIKit

// --- Constants ---
private let handleWidth: CGFloat = 10.0
private let selectedBorderWidth: CGFloat = 2.0
private let defaultBorderWidth: CGFloat = 1.5

/// A view representing a single video clip in the timeline.
/// It handles its own UI elements like handles, a label, and a thumbnail track.
class VideoClipViewHera: UIView {

    // MARK: - Properties

    var clipId: Int
    var initialWidth: CGFloat
    var trimOffset: CGFloat = 0.0 {
        didSet {
            updateMiniTimelinePosition()
        }
    }

    // --- UI Components ---
    private let miniTimelineView = UIView()
    private let clipLabel = UILabel()
    let leftHandle = UIView()
    let rightHandle = UIView()

    // --- State ---
    var isSelected: Bool = false {
        didSet {
            updateSelectionAppearance()
        }
    }

    // MARK: - Initialization

    init(frame: CGRect, clipId: Int, title: String) {
        self.clipId = clipId
        self.initialWidth = frame.width
        super.init(frame: frame)
        
        setupView()
        setupSubviews(title: title)
        generateMiniTimeline()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        // Manually position and size all subviews
        leftHandle.frame = CGRect(x: 0, y: 0, width: handleWidth, height: bounds.height)
        rightHandle.frame = CGRect(x: bounds.width - handleWidth, y: 0, width: handleWidth, height: bounds.height)
        clipLabel.frame = bounds
        
        // Update mini timeline frame with proper bounds
        let miniTimelineWidth = max(bounds.width + trimOffset, initialWidth)
        miniTimelineView.frame = CGRect(x: -trimOffset, y: 0, width: miniTimelineWidth, height: bounds.height)
    }

    // MARK: - Setup

    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = defaultBorderWidth
        self.layer.borderColor = UIColor(red: 224/255, green: 227/255, blue: 234/255, alpha: 1.0).cgColor
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1.0
        self.clipsToBounds = true // This is key for the trimming effect
    }

    private func setupSubviews(title: String) {
        // Mini Timeline (Thumbnail Track)
        miniTimelineView.backgroundColor = .clear
        miniTimelineView.clipsToBounds = true
        miniTimelineView.isUserInteractionEnabled = false
        addSubview(miniTimelineView)

        // Clip Label
        clipLabel.text = title
        clipLabel.textColor = UIColor(red: 43/255, green: 45/255, blue: 52/255, alpha: 1.0)
        clipLabel.font = .systemFont(ofSize: 16, weight: .medium)
        clipLabel.textAlignment = .center
        clipLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        clipLabel.layer.cornerRadius = 4.0
        clipLabel.layer.masksToBounds = true
        addSubview(clipLabel)

        // Left Handle
        leftHandle.backgroundColor = UIColor(red: 51/255, green: 135/255, blue: 255/255, alpha: 1.0)
        leftHandle.layer.cornerRadius = 4.0
        leftHandle.isUserInteractionEnabled = true
        leftHandle.isHidden = !isSelected // Initially hidden
        
        // Add a visual indicator to the handle
        let leftIndicator = UIView()
        leftIndicator.backgroundColor = .white
        leftIndicator.layer.cornerRadius = 1.0
        leftIndicator.frame = CGRect(x: 3, y: bounds.height/2 - 8, width: 2, height: 16)
        leftHandle.addSubview(leftIndicator)
        
        addSubview(leftHandle)

        // Right Handle
        rightHandle.backgroundColor = UIColor(red: 51/255, green: 135/255, blue: 255/255, alpha: 1.0)
        rightHandle.layer.cornerRadius = 4.0
        rightHandle.isUserInteractionEnabled = true
        rightHandle.isHidden = !isSelected // Initially hidden
        
        // Add a visual indicator to the handle
        let rightIndicator = UIView()
        rightIndicator.backgroundColor = .white
        rightIndicator.layer.cornerRadius = 1.0
        rightIndicator.frame = CGRect(x: 5, y: bounds.height/2 - 8, width: 2, height: 16)
        rightHandle.addSubview(rightIndicator)
        
        addSubview(rightHandle)
    }

    // MARK: - Public Methods

    /// Updates the visual appearance based on the selection state.
    func updateSelectionAppearance() {
        leftHandle.isHidden = !isSelected
        rightHandle.isHidden = !isSelected
        
        if isSelected {
            layer.borderColor = UIColor(red: 51/255, green: 135/255, blue: 255/255, alpha: 1.0).cgColor
            layer.borderWidth = selectedBorderWidth
            layer.shadowColor = UIColor(red: 51/255, green: 135/255, blue: 255/255, alpha: 0.13).cgColor
            layer.shadowRadius = 8.0
            layer.shadowOpacity = 1.0
            superview?.bringSubviewToFront(self) // Ensure selected clip is on top
            
            // Bring label to front when selected
            bringSubviewToFront(clipLabel)
            bringSubviewToFront(leftHandle)
            bringSubviewToFront(rightHandle)
        } else {
            layer.borderColor = UIColor(red: 224/255, green: 227/255, blue: 234/255, alpha: 1.0).cgColor
            layer.borderWidth = defaultBorderWidth
            layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
            layer.shadowRadius = 4.0
        }
    }

    // MARK: - Private Helpers

    /// Simulates an infinitely long thumbnail track, just like the web version.
    private func generateMiniTimeline() {
        let colors: [UIColor] = [
            UIColor.systemBlue.withAlphaComponent(0.3),
            UIColor.systemOrange.withAlphaComponent(0.3),
            UIColor.systemGreen.withAlphaComponent(0.3),
            UIColor.systemRed.withAlphaComponent(0.3),
            UIColor.systemPurple.withAlphaComponent(0.3),
            UIColor.systemYellow.withAlphaComponent(0.3)
        ]
        let thumbWidth: CGFloat = 18.0
        let thumbGap: CGFloat = 3.0
        let totalThumbs = Int(1200 / (thumbWidth + thumbGap)) // Simulate a very wide timeline

        for i in 0..<totalThumbs {
            let thumbView = UIView()
            thumbView.backgroundColor = colors[i % colors.count]
            thumbView.layer.cornerRadius = 3.0
            thumbView.layer.borderWidth = 0.5
            thumbView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            thumbView.frame = CGRect(
                x: CGFloat(i) * (thumbWidth + thumbGap),
                y: 4,
                width: thumbWidth,
                height: bounds.height - 8
            )
            miniTimelineView.addSubview(thumbView)
        }
    }
    
    /// Updates the horizontal position of the thumbnail track to create the illusion of it sliding.
    private func updateMiniTimelinePosition() {
        let miniTimelineWidth = max(bounds.width + trimOffset, initialWidth)
        miniTimelineView.frame = CGRect(x: -trimOffset, y: 0, width: miniTimelineWidth, height: bounds.height)
    }
    
    // MARK: - Override for Better Touch Handling
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Expand the touch area slightly for better usability
        let expandedBounds = bounds.insetBy(dx: -5, dy: -5)
        return expandedBounds.contains(point)
    }
}
