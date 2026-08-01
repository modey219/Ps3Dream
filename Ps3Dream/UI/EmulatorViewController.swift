// Ps3Dream iOS - Emulator View Controller
// Main emulation screen with Metal rendering surface and virtual controller

import UIKit
import Metal
import MetalKit
import QuartzCore

class EmulatorViewController: UIViewController {

    private let game: PS3Game
    private var metalView: MTKView!
    private var commandQueue: MTLCommandQueue?
    private var isPaused = false

    private var virtualPadOverlay: VirtualPadOverlay!
    private var fpsLabel: UILabel!
    private var fpsDisplayLink: CADisplayLink?
    private var frameCount: Int = 0
    private var lastFPSTime: CFTimeInterval = 0

    init(game: PS3Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setNeedsStatusBarAppearanceUpdate()

        setupMetal()
        setupVirtualPad()
        setupToolbar()

        if AppSettings.shared.showFPS {
            setupFPSCounter()
        }
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startEmulation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ps3dream_pause()
    }

    deinit {
        fpsDisplayLink?.invalidate()
    }

    // MARK: - Metal Setup

    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            showError("Metal is not supported on this device.")
            return
        }

        metalView = MTKView(frame: view.bounds, device: device)
        metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.preferredFramesPerSecond = 60
        metalView.enableSetNeedsDisplay = false
        metalView.isPaused = false
        metalView.framebufferOnly = false
        view.addSubview(metalView)

        commandQueue = device.makeCommandQueue()

        if let layer = metalView.layer as? CAMetalLayer {
            let width = Int(metalView.drawableSize.width)
            let height = Int(metalView.drawableSize.height)
            ps3dream_set_surface(
                Unmanaged.passUnretained(layer).toOpaque(),
                Int32(width), Int32(height))
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layer = metalView.layer as? CAMetalLayer {
            let width = Int(metalView.drawableSize.width)
            let height = Int(metalView.drawableSize.height)
            ps3dream_resize(Int32(width), Int32(height))
        }
    }

    // MARK: - FPS Counter

    private func setupFPSCounter() {
        fpsLabel = UILabel()
        fpsLabel.textColor = .green
        fpsLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fpsLabel)

        NSLayoutConstraint.activate([
            fpsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            fpsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])

        fpsDisplayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        fpsDisplayLink?.add(to: .main, forMode: .common)
        lastFPSTime = CACurrentMediaTime()
    }

    @objc private func updateFPS() {
        frameCount += 1
        let now = CACurrentMediaTime()
        let elapsed = now - lastFPSTime
        if elapsed >= 1.0 {
            let fps = Double(frameCount) / elapsed
            fpsLabel.text = String(format: "%.0f FPS", fps)
            frameCount = 0
            lastFPSTime = now
        }
    }

    // MARK: - Virtual Pad

    private func setupVirtualPad() {
        virtualPadOverlay = VirtualPadOverlay(frame: view.bounds)
        virtualPadOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        virtualPadOverlay.delegate = self
        virtualPadOverlay.alpha = CGFloat(AppSettings.shared.padOpacity)
        view.addSubview(virtualPadOverlay)
    }

    // MARK: - Toolbar

    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        let pauseBtn = UIBarButtonItem(
            image: UIImage(systemName: "pause.fill"), style: .plain,
            target: self, action: #selector(togglePause))
        let screenshotBtn = UIBarButtonItem(
            image: UIImage(systemName: "camera"), style: .plain,
            target: self, action: #selector(takeScreenshot))
        let quitBtn = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle"), style: .plain,
            target: self, action: #selector(quitGame))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [pauseBtn, spacer, screenshotBtn, quitBtn]

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Emulation Control

    private func startEmulation() {
        ps3dream_boot_game(game.gamePath)
        ps3dream_boot()
    }

    @objc private func togglePause() {
        if ps3dream_is_running() {
            ps3dream_pause()
            isPaused = true
        } else if ps3dream_is_paused() {
            ps3dream_resume()
            isPaused = false
        }
    }

    @objc private func takeScreenshot() {
        guard let drawable = metalView.currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return }

        let width = drawable.texture.width
        let height = drawable.texture.height
        let bytesPerRow = width * 4
        let totalBytes = bytesPerRow * height

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .renderTarget]
        textureDescriptor.storageMode = .shared

        guard let stagingTexture = metalView.device?.makeTexture(descriptor: textureDescriptor) else { return }

        blitEncoder.copy(from: drawable.texture, sourceSlice: 0, sourceLevel: 0,
                        sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                        sourceSize: MTLSize(width: width, height: height, depth: 1),
                        to: stagingTexture, destinationSlice: 0, destinationLevel: 0,
                        destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let data = UnsafeMutableRawPointer.allocate(byteCount: totalBytes, alignment: 4)
        defer { data.deallocate() }
        stagingTexture.getBytes(data, bytesPerRow: bytesPerRow,
                               from: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                                               size: MTLSize(width: width, height: height, depth: 1)),
                               mipmapLevel: 0)

        let cgContext = CGContext(data: data, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue |
                                             CGImageAlphaInfo.premultipliedFirst.rawValue)
        if let cgImage = cgContext?.makeImage() {
            let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .downMirrored)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }

    @objc private func quitGame() {
        let alert = UIAlertController(title: "Quit Game", message: "Return to game list?",
                                       preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Quit", style: .destructive) { _ in
            ps3dream_quit()
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - VirtualPadDelegate

extension EmulatorViewController: VirtualPadDelegate {
    func virtualPad(_ overlay: VirtualPadOverlay, didPressButton button: String, pressed: Bool) {
        let keyCode = EmulatorManager.buttonToKeyCode(button)
        ps3dream_key_event(Int32(keyCode), pressed, pressed ? 255 : 0)
    }

    func virtualPad(_ overlay: VirtualPadOverlay, didMoveStick stick: String, x: Float, y: Float) {
        EmulatorManager.shared.sendStick(stick, x: x, y: y)
    }
}
