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

    // Virtual pad state
    private var buttonStates: [String: Bool] = [:]
    private var virtualPadOverlay: VirtualPadOverlay!

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

    // MARK: - Metal Setup

    private func setupMetal() {
        metalView = MTKView(frame: view.bounds, device: MTLCreateSystemDefaultDevice())
        metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.preferredFramesPerSecond = 60
        metalView.enableSetNeedsDisplay = false
        metalView.isPaused = false
        view.addSubview(metalView)

        commandQueue = metalView.device?.makeCommandQueue()

        // Set up the rendering surface for the emulator
        if let layer = metalView.layer as? CAMetalLayer {
            layer.framebufferOnly = false
            let width = Int(metalView.drawableSize.width)
            let height = Int(metalView.drawableSize.height)
            ps3dream_set_surface(Unmanaged.passUnretained(layer).toOpaque(), Int32(width), Int32(height))
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layer = metalView.layer as? CAMetalLayer {
            let width = Int(metalView.drawableSize.width)
            let height = Int(metalView.drawableSize.height)
            ps3dream_resize(Int32(width), Int32(height))
            _ = layer
        }
    }

    // MARK: - Virtual Pad

    private func setupVirtualPad() {
        virtualPadOverlay = VirtualPadOverlay(frame: view.bounds)
        virtualPadOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        virtualPadOverlay.delegate = self
        view.addSubview(virtualPadOverlay)
    }

    // MARK: - Toolbar

    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        let pauseBtn = UIBarButtonItem(image: UIImage(systemName: "pause.fill"), style: .plain,
                                       target: self, action: #selector(togglePause))
        let quitBtn = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"), style: .plain,
                                      target: self, action: #selector(quitGame))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [pauseBtn, spacer, quitBtn]

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Emulation Control

    private func startEmulation() {
        // Enable JIT first
        if !ios_jit_enabled() {
            ios_enable_jit()
        }

        let path = game.gamePath
        ps3dream_boot_game(path)
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
}

// MARK: - VirtualPadDelegate

extension EmulatorViewController: VirtualPadDelegate {
    func virtualPad(_ overlay: VirtualPadOverlay, didPressButton button: String, pressed: Bool) {
        let keyCode = mapButtonToKeyCode(button)
        ps3dream_key_event(Int32(keyCode), pressed, pressed ? 255 : 0)
    }

    func virtualPad(_ overlay: VirtualPadOverlay, didMoveStick stick: String, x: Float, y: Float) {
        // Map analog stick to axis events
        if stick == "left" {
            ps3dream_key_event(100, x < -0.1, Int32(abs(x) * 255))
            ps3dream_key_event(101, x > 0.1, Int32(abs(x) * 255))
            ps3dream_key_event(102, y < -0.1, Int32(abs(y) * 255))
            ps3dream_key_event(103, y > 0.1, Int32(abs(y) * 255))
        } else {
            ps3dream_key_event(104, x < -0.1, Int32(abs(x) * 255))
            ps3dream_key_event(105, x > 0.1, Int32(abs(x) * 255))
            ps3dream_key_event(106, y < -0.1, Int32(abs(y) * 255))
            ps3dream_key_event(107, y > 0.1, Int32(abs(y) * 255))
        }
    }

    private func mapButtonToKeyCode(_ button: String) -> Int {
        switch button {
        case "cross":     return 0  // A
        case "circle":    return 1  // B
        case "square":    return 2  // X
        case "triangle":  return 3  // Y
        case "l1":        return 4
        case "r1":        return 5
        case "l2":        return 6
        case "r2":        return 7
        case "share":     return 8
        case "options":   return 9
        case "ps":        return 10
        case "l3":        return 11
        case "r3":        return 12
        case "dpad_up":   return 13
        case "dpad_down": return 14
        case "dpad_left": return 15
        case "dpad_right":return 16
        default: return 0
        }
    }
}
