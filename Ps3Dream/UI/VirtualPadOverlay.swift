// Ps3Dream iOS - Virtual Controller Overlay
// On-screen touch controls for PS3 gamepad

import UIKit

protocol VirtualPadDelegate: AnyObject {
    func virtualPad(_ overlay: VirtualPadOverlay, didPressButton button: String, pressed: Bool)
    func virtualPad(_ overlay: VirtualPadOverlay, didMoveStick stick: String, x: Float, y: Float)
}

class VirtualPadOverlay: UIView {

    weak var delegate: VirtualPadDelegate?

    private var buttons: [String: UIButton] = [:]
    private var leftStickCenter: CGPoint = .zero
    private var rightStickCenter: CGPoint = .zero
    private var leftStickKnob: UIView!
    private var rightStickKnob: UIView!

    private let stickRadius: CGFloat = 50
    private let buttonSize: CGFloat = 52

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPad()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupPad() {
        isMultipleTouchEnabled = true
        backgroundColor = .clear

        // D-Pad
        let dpadPositions: [(String, CGFloat, CGFloat)] = [
            ("dpad_up", 0, -40), ("dpad_down", 0, 40),
            ("dpad_left", -40, 0), ("dpad_right", 40, 0)
        ]
        for (name, ox, oy) in dpadPositions {
            let btn = createButton(name: name, color: UIColor.white.withAlphaComponent(0.3))
            btn.tag = 100
            buttons[name] = btn
            addSubview(btn)
        }

        // Face buttons
        let facePositions: [(String, CGFloat, CGFloat)] = [
            ("cross", 0, 36), ("circle", 36, 0),
            ("square", -36, 0), ("triangle", 0, -36)
        ]
        let faceColors: [String: UIColor] = [
            "cross": .systemBlue, "circle": .systemRed,
            "square": .systemPurple, "triangle": .systemGreen
        ]
        for (name, ox, oy) in facePositions {
            let btn = createButton(name: name, color: faceColors[name] ?? .white)
            btn.tag = 101
            buttons[name] = btn
            addSubview(btn)
        }

        // Shoulder buttons
        for name in ["l1", "r1", "l2", "r2"] {
            let btn = createButton(name: name, color: UIColor.white.withAlphaComponent(0.25))
            btn.tag = 102
            btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
            buttons[name] = btn
            addSubview(btn)
        }

        // System buttons
        for name in ["share", "options"] {
            let btn = createButton(name: name, color: UIColor.white.withAlphaComponent(0.2))
            btn.tag = 103
            btn.titleLabel?.font = .systemFont(ofSize: 9, weight: .medium)
            buttons[name] = btn
            addSubview(btn)
        }

        // Analog sticks
        leftStickKnob = createStickKnob()
        rightStickKnob = createStickKnob()
        addSubview(leftStickKnob)
        addSubview(rightStickKnob)
    }

    private func createButton(name: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(buttonLabel(name), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.backgroundColor = color.withAlphaComponent(0.35)
        btn.layer.cornerRadius = buttonSize / 2
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = color.withAlphaComponent(0.6).cgColor
        btn.tag = buttons.count
        btn.addTarget(self, action: #selector(buttonPressed(_:)), for: [.touchDown, .touchDragEnter])
        btn.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit])
        return btn
    }

    private func buttonLabel(_ name: String) -> String {
        switch name {
        case "cross": return "X"
        case "circle": return "O"
        case "square": return "\u{25A0}"
        case "triangle": return "\u{25B2}"
        case "l1": return "L1"
        case "r1": return "R1"
        case "l2": return "L2"
        case "r2": return "R2"
        case "share": return "SH"
        case "options": return "OP"
        default: return ""
        }
    }

    private func createStickKnob() -> UIView {
        let knob = UIView(frame: CGRect(x: 0, y: 0, width: stickRadius * 2, height: stickRadius * 2))
        knob.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        knob.layer.cornerRadius = stickRadius
        knob.layer.borderWidth = 1.5
        knob.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        let inner = UIView(frame: CGRect(x: stickRadius - 16, y: stickRadius - 16, width: 32, height: 32))
        inner.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        inner.layer.cornerRadius = 16
        inner.tag = 999
        knob.addSubview(inner)
        return knob
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height

        // D-Pad (bottom-left)
        let dpadCenter = CGPoint(x: 110, y: h - 110)
        for name in ["dpad_up", "dpad_down", "dpad_left", "dpad_right"] {
            guard let btn = buttons[name] else { continue }
            var ox: CGFloat = 0, oy: CGFloat = 0
            switch name {
            case "dpad_up": oy = -40
            case "dpad_down": oy = 40
            case "dpad_left": ox = -40
            case "dpad_right": ox = 40
            default: break
            }
            btn.frame = CGRect(x: dpadCenter.x + ox - buttonSize/2, y: dpadCenter.y + oy - buttonSize/2,
                               width: buttonSize, height: buttonSize)
        }

        // Face buttons (bottom-right)
        let faceCenter = CGPoint(x: w - 110, y: h - 110)
        for name in ["cross", "circle", "square", "triangle"] {
            guard let btn = buttons[name] else { continue }
            var ox: CGFloat = 0, oy: CGFloat = 0
            switch name {
            case "cross": oy = 36
            case "circle": ox = 36
            case "square": ox = -36
            case "triangle": oy = -36
            default: break
            }
            btn.frame = CGRect(x: faceCenter.x + ox - buttonSize/2, y: faceCenter.y + oy - buttonSize/2,
                               width: buttonSize, height: buttonSize)
        }

        // Shoulders (top)
        let shoulderW: CGFloat = 80
        let shoulderH: CGFloat = 30
        buttons["l1"]?.frame = CGRect(x: 20, y: 60, width: shoulderW, height: shoulderH)
        buttons["r1"]?.frame = CGRect(x: w - 20 - shoulderW, y: 60, width: shoulderW, height: shoulderH)
        buttons["l2"]?.frame = CGRect(x: 20, y: 96, width: shoulderW, height: shoulderH)
        buttons["r2"]?.frame = CGRect(x: w - 20 - shoulderW, y: 96, width: shoulderW, height: shoulderH)

        // System buttons
        let sysBtnW: CGFloat = 32
        buttons["share"]?.frame = CGRect(x: w/2 - 60, y: 70, width: sysBtnW, height: 24)
        buttons["options"]?.frame = CGRect(x: w/2 + 28, y: 70, width: sysBtnW, height: 24)

        // Analog sticks
        leftStickCenter = CGPoint(x: 110, y: h - 260)
        rightStickCenter = CGPoint(x: w - 110, y: h - 260)
        leftStickKnob.center = leftStickCenter
        rightStickKnob.center = rightStickCenter
    }

    // MARK: - Touch Handling

    @objc private func buttonPressed(_ sender: UIButton) {
        guard let name = buttons.first(where: { $0.value === sender })?.key else { return }
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        delegate?.virtualPad(self, didPressButton: name, pressed: true)
    }

    @objc private func buttonReleased(_ sender: UIButton) {
        guard let name = buttons.first(where: { $0.value === sender })?.key else { return }
        sender.transform = .identity
        delegate?.virtualPad(self, didPressButton: name, pressed: false)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            let prev = touch.previousLocation(in: self)

            let distLeft = hypot(loc.x - leftStickCenter.x, loc.y - leftStickCenter.y)
            if distLeft < stickRadius * 2 {
                let dx = (loc.x - leftStickCenter.x) / stickRadius
                let dy = (loc.y - leftStickCenter.y) / stickRadius
                let clampedX = max(-1, min(1, dx))
                let clampedY = max(-1, min(1, dy))
                leftStickKnob.center = CGPoint(
                    x: leftStickCenter.x + clampedX * stickRadius * 0.8,
                    y: leftStickCenter.y + clampedY * stickRadius * 0.8)
                delegate?.virtualPad(self, didMoveStick: "left", x: Float(clampedX), y: Float(clampedY))
            }

            let distRight = hypot(loc.x - rightStickCenter.x, loc.y - rightStickCenter.y)
            if distRight < stickRadius * 2 {
                let dx = (loc.x - rightStickCenter.x) / stickRadius
                let dy = (loc.y - rightStickCenter.y) / stickRadius
                let clampedX = max(-1, min(1, dx))
                let clampedY = max(-1, min(1, dy))
                rightStickKnob.center = CGPoint(
                    x: rightStickCenter.x + clampedX * stickRadius * 0.8,
                    y: rightStickCenter.y + clampedY * stickRadius * 0.8)
                delegate?.virtualPad(self, didMoveStick: "right", x: Float(clampedX), y: Float(clampedY))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            let distLeft = hypot(loc.x - leftStickCenter.x, loc.y - leftStickCenter.y)
            if distLeft < stickRadius * 2 {
                leftStickKnob.center = leftStickCenter
                delegate?.virtualPad(self, didMoveStick: "left", x: 0, y: 0)
            }
            let distRight = hypot(loc.x - rightStickCenter.x, loc.y - rightStickCenter.y)
            if distRight < stickRadius * 2 {
                rightStickKnob.center = rightStickCenter
                delegate?.virtualPad(self, didMoveStick: "right", x: 0, y: 0)
            }
        }
    }
}
