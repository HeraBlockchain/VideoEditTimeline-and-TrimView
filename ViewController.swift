// Mamunur Rahaman Hera
import UIKit

/// The main view controller that manages the timeline and its clips.
/// It handles all user interactions like tapping to select and dragging handles to trim.
class ViewController: UIViewController {

    // MARK: - UI Components
    private let timelineScrollView = UIScrollView()
    private let timelineContentView = UIView()
    private var clips: [VideoClipViewHera] = []

    // MARK: - Drag State
    private var initialWidths: [CGFloat] = []
    private var dragStartPoint: CGPoint = .zero
    private var draggedClip: (view: VideoClipViewHera, handle: UIView)?

    // MARK: - Constants
    private let minClipWidth: CGFloat = 60.0
    private let maxClipWidth: CGFloat = 320.0
    private let timelinePadding: CGFloat = 20.0
    private let clipHeight: CGFloat = 48.0
    private let timelineHeight: CGFloat = 80.0
    private let contentPadding: CGFloat = 10.0

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createClips()
        setupGestureRecognizers()
        updateClipFrames(animated: false)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 244/255, green: 246/255, blue: 251/255, alpha: 1.0)

        // Timeline ScrollView Container
        timelineScrollView.backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1.0)
        timelineScrollView.layer.cornerRadius = 10.0
        timelineScrollView.layer.borderWidth = 1.5
        timelineScrollView.layer.borderColor = UIColor(red: 224/255, green: 227/255, blue: 234/255, alpha: 1.0).cgColor
        timelineScrollView.showsHorizontalScrollIndicator = true
        timelineScrollView.showsVerticalScrollIndicator = false
        timelineScrollView.bounces = true
        timelineScrollView.alwaysBounceHorizontal = true
        timelineScrollView.frame = CGRect(x: timelinePadding, y: 500, width: view.bounds.width - (timelinePadding * 2), height: timelineHeight)
        view.addSubview(timelineScrollView)

        // Timeline Content View (this will hold all the clips)
        timelineContentView.backgroundColor = .clear
        timelineScrollView.addSubview(timelineContentView)
    }

    private func createClips() {
        initialWidths = [200, 200, 200]
        let titles = ["C1", "C2", "C3"]

        for i in 0..<initialWidths.count {
            let frame = CGRect(x: 0, y: (timelineHeight - clipHeight) / 2, width: initialWidths[i], height: clipHeight)
            let clip = VideoClipViewHera(frame: frame, clipId: i, title: titles[i])
            clips.append(clip)
            timelineContentView.addSubview(clip)
        }

        // Select the first clip by default
        clips.first?.isSelected = true
    }

    private func setupGestureRecognizers() {
        // Tap to select a clip
        for clip in clips {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleClipTap(_:)))
            clip.addGestureRecognizer(tapGesture)

            // Pan for left handle
            let leftPan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            clip.leftHandle.addGestureRecognizer(leftPan)

            // Pan for right handle
            let rightPan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            clip.rightHandle.addGestureRecognizer(rightPan)
        }

        // Tap to deselect all
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        timelineScrollView.addGestureRecognizer(backgroundTap)
    }

    // MARK: - Layout

    /// Recalculates and sets the frames for all clips and updates scroll view content size.
    /// This is the core layout function, equivalent to `updatePositions` in the web version.
    private func updateClipFrames(animated: Bool, newLefts: [CGFloat]? = nil) {
        var currentX: CGFloat = contentPadding
        var totalWidth: CGFloat = 0

        let animationBlock = {
            for i in 0..<self.clips.count {
                let clip = self.clips[i]
                var newFrame = clip.frame
                newFrame.size.width = self.initialWidths[i]
                
                if let newLefts = newLefts, i < newLefts.count {
                    newFrame.origin.x = newLefts[i]
                } else {
                    newFrame.origin.x = currentX
                }
                
                clip.frame = newFrame
                currentX = newFrame.origin.x + newFrame.size.width
            }
            totalWidth = currentX + self.contentPadding
            
            // Update content view and scroll view content size
            self.timelineContentView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: self.timelineHeight)
            self.timelineScrollView.contentSize = CGSize(width: totalWidth, height: self.timelineHeight)
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.5, options: .curveEaseOut, animations: animationBlock)
        } else {
            animationBlock()
        }
    }

    /// Scrolls to make the specified clip visible in the timeline
    private func scrollToClip(_ clip: VideoClipViewHera, animated: Bool = true) {
        let clipFrame = clip.frame
        let visibleRect = timelineScrollView.bounds
        
        // Check if clip is already fully visible
        if visibleRect.contains(clipFrame) {
            return
        }
        
        // Calculate the target scroll position
        var targetX = clipFrame.origin.x - contentPadding
        
        // Ensure we don't scroll beyond the content bounds
        let maxScrollX = max(0, timelineScrollView.contentSize.width - timelineScrollView.bounds.width)
        targetX = min(max(0, targetX), maxScrollX)
        
        timelineScrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: animated)
    }

    // MARK: - Gesture Handlers

    @objc private func handleClipTap(_ sender: UITapGestureRecognizer) {
        guard let selectedView = sender.view as? VideoClipViewHera else { return }
        
        for clip in clips {
            clip.isSelected = (clip == selectedView)
        }
        
        // Scroll to make the selected clip visible
        scrollToClip(selectedView)
    }

    @objc private func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        // Deselect all if the tap is outside any clip
        let tapLocation = sender.location(in: timelineContentView)
        if clips.allSatisfy({ !($0.frame.contains(tapLocation)) }) {
            for clip in clips {
                clip.isSelected = false
            }
        }
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view, let clip = handle.superview as? VideoClipViewHera else { return }

        switch sender.state {
        case .began:
            // --- Start Dragging ---
            draggedClip = (clip, handle)
            dragStartPoint = sender.location(in: view)
            // Store the widths at the beginning of the drag
            initialWidths = clips.map { $0.frame.width }
            
            // Disable scrolling during drag
            timelineScrollView.isScrollEnabled = false

        case .changed:
            // --- Continue Dragging ---
            guard let dragged = draggedClip else { return }
            let currentLocation = sender.location(in: view)
            let dx = currentLocation.x - dragStartPoint.x

            if dragged.handle == dragged.view.rightHandle {
                // --- Right Handle Drag (Ripple Edit) ---
                var newWidth = initialWidths[dragged.view.clipId] + dx
                let clampedDx: CGFloat
                
                if newWidth < minClipWidth {
                    newWidth = minClipWidth
                    clampedDx = newWidth - initialWidths[dragged.view.clipId]
                } else if newWidth > maxClipWidth {
                    newWidth = maxClipWidth
                    clampedDx = newWidth - initialWidths[dragged.view.clipId]
                } else {
                    clampedDx = dx
                }
                
                // 1. Update the dragged clip's width
                var frame = dragged.view.frame
                frame.size.width = newWidth
                dragged.view.frame = frame
                
                // 2. Calculate starting positions of all clips
                var startLefts: [CGFloat] = []
                var currentLeft: CGFloat = contentPadding
                for width in initialWidths {
                    startLefts.append(currentLeft)
                    currentLeft += width
                }
                
                // 3. Ripple-move all clips to the right of the dragged clip
                for i in (dragged.view.clipId + 1)..<clips.count {
                    var clipFrame = clips[i].frame
                    clipFrame.origin.x = startLefts[i] + clampedDx
                    clips[i].frame = clipFrame
                }
                
                // Update scroll view content size in real-time
                updateScrollViewContentSize()
                
            } else if dragged.handle == dragged.view.leftHandle {
                // --- Left Handle Drag (Ripple Edit) ---
                var newWidth = initialWidths[dragged.view.clipId] - dx
                let clampedDx: CGFloat
                
                if newWidth < minClipWidth {
                    newWidth = minClipWidth
                    clampedDx = initialWidths[dragged.view.clipId] - minClipWidth
                } else if newWidth > maxClipWidth {
                    newWidth = maxClipWidth
                    clampedDx = initialWidths[dragged.view.clipId] - maxClipWidth
                } else {
                    clampedDx = dx
                }

                // 1. Update thumbnail offset
                dragged.view.trimOffset = max(0, dragged.view.initialWidth - newWidth)

                // 2. Calculate starting positions of all clips
                var startLefts: [CGFloat] = []
                var currentLeft: CGFloat = contentPadding
                for width in initialWidths {
                    startLefts.append(currentLeft)
                    currentLeft += width
                }

                // 3. Ripple-move the current clip and all preceding clips
                for i in 0...dragged.view.clipId {
                    var frame = clips[i].frame
                    frame.origin.x = startLefts[i] + clampedDx
                    clips[i].frame = frame
                }
                
                // 4. Update the width of the dragged clip
                var frame = dragged.view.frame
                frame.size.width = newWidth
                dragged.view.frame = frame
                
                // Update scroll view content size in real-time
                updateScrollViewContentSize()
            }

        case .ended, .cancelled:
            // --- End Dragging ---
            guard let dragged = draggedClip else { return }
            
            // Re-enable scrolling
            timelineScrollView.isScrollEnabled = true
            
            // Finalize the width change in our source of truth array
            initialWidths = clips.map { $0.frame.width }
            
            // Update the stored initial width for the clip itself for future trims
            dragged.view.initialWidth = dragged.view.frame.width
            
            draggedClip = nil
            updateClipFrames(animated: true)

        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    /// Updates the scroll view content size based on current clip positions
    private func updateScrollViewContentSize() {
        guard !clips.isEmpty else { return }
        
        let rightmostClip = clips.max { $0.frame.maxX < $1.frame.maxX }
        let totalWidth = (rightmostClip?.frame.maxX ?? 0) + contentPadding
        
        timelineContentView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: timelineHeight)
        timelineScrollView.contentSize = CGSize(width: totalWidth, height: timelineHeight)
    }
}
