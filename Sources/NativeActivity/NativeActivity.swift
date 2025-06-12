import AndroidLog
import AndroidEntry
import NativeAppGlue

private var instance: android_app {
    _read {
        yield application.pointee
    }
    _modify {
        yield &application.pointee
    }
}

public class NativeActivity: @unchecked Sendable {
    public weak var delegate: NativeActivityDelegate?
    private var handler: Handler?
    private var state = ControllerState()
    
    public init() {
        handler = Handler(handle_cmd: handle_cmd, handle_input: handle_input)
        
        instance.userData = withUnsafeMutablePointer(to: &handler, { UnsafeMutableRawPointer($0) })
        instance.onAppCmd = onAppCmd
        instance.onInputEvent = onInputEvent
    }
    
    deinit {
        instance.userData = nil
        instance.onAppCmd = nil
        instance.onInputEvent = nil
    }
    
    public func run() {
        delegate?.launch()
        
        let pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?> = .allocate(capacity: 1)
        defer {
            pointer.deinitialize(count: 1)
            pointer.deallocate()
        }
        
        var events: CInt = 0
        
        repeat {
            var animating: Bool { instance.window != nil }
            let timeout: CInt = animating ? 0 : -1
            ALooper_pollOnce(timeout, nil, &events, pointer)
            
            if let source = pointer.pointee?.assumingMemoryBound(to: android_poll_source.self) {
                source.pointee.process(source.pointee.app, source)
            }
            
            if animating {
                delegate?.animate()
            }
        } while instance.destroyRequested == 0
        
        delegate?.destroy()
    }
    
    public func destroy() {
        guard instance.activityState == APP_CMD_RESUME else { return }
        
        ANativeActivity_finish(instance.activity)
    }
}

extension NativeActivity: ApplicationCommand {
    func resume(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        delegate?.foreground(window: window)
    }
    
    func pause(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        delegate?.background(window: window)
    }
    
    func gainedFocus(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        delegate?.active(window: window)
    }
    
    func lostFocus(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        delegate?.resign(window: window)
    }
    
    func initializeWindow(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        ANativeWindow_acquire(window)
        
        delegate?.initialize(window: window)
    }
    
    func terminateWindow(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        delegate?.terminate(window: window)
        
        ANativeWindow_release(window)
    }
    
    func contentRectChanged(app: UnsafeMutablePointer<android_app>) {
        let window = app.pointee.window
        
        let width = ANativeWindow_getWidth(window)
        let height = ANativeWindow_getHeight(window)
        
        delegate?.layout(window: window, width: width, height: height)
    }
}

extension NativeActivity: ApplicationInput {
    func input(app: UnsafeMutablePointer<android_app>, event: OpaquePointer?) throws {
        guard let type = InputEventType(event: event),
              let source = InputEventSource(event: event) else { return }
        
        switch source {
        case .keyboard:
            try keyboard(app: app, type: type, event: event)
        case .joystick:
            try joystick(app: app, type: type, event: event)
        case .touchscreen:
            try touchscreen(app: app, type: type, event: event)
        case .mouse:
            try mouse(app: app, type: type, event: event)
        case .dpad, .gamepad, .stylus, .bluetoothStylus, .trackball, .mouseRelative,
                .touchpad, .touchNavigation, .hdmi, .sensor, .rotaryEncoder:
            throw NativeActivityInputError.unspecifiedSource
        case .unknown, .none:
            throw NativeActivityInputError.unhandledEvent
        }
    }
    
    private func keyboard(
        app: UnsafeMutablePointer<android_app>,
        type: InputEventType,
        event: OpaquePointer?
    ) throws {
        guard type == .key else {
            throw NativeActivityInputError.keyboardType
        }
        guard let action = KeyEventAction(event: event) else {
            throw NativeActivityInputError.keyboardValue
        }
        guard let key = KeyEventCode(event: event), key != .unknown else {
            return
        }
        let flags = KeyEventFlags(event: event)
        
        if key == .back, flags.contains(.fromSystem) {
            if action == .down {
                delegate?.back()
            }
        } else {
            let value = action == .down
            switch key {
            case .buttonA:
                guard state.a != value else { break }
                delegate?.toggle(key: key, value: value)
                state.a = value
            case .buttonB:
                guard state.b != value else { break }
                delegate?.toggle(key: key, value: value)
                state.b = value
            case .buttonX:
                guard state.x != value else { break }
                delegate?.toggle(key: key, value: value)
                state.x = value
            case .buttonY:
                guard state.y != value else { break }
                delegate?.toggle(key: key, value: value)
                state.y = value
                
            case .buttonL1:
                guard state.l1 != value else { break }
                delegate?.toggle(key: key, value: value)
                state.l1 = value
            case .buttonR1:
                guard state.r1 != value else { break }
                delegate?.toggle(key: key, value: value)
                state.r1 = value
            case .buttonL2:
                guard state.l2 != value else { break }
                delegate?.toggle(key: key, value: value)
                state.l2 = value
            case .buttonR2:
                guard state.r2 != value else { break }
                delegate?.toggle(key: key, value: value)
                state.r2 = value
            case .buttonThumbL:
                guard state.l3 != value else { break }
                delegate?.toggle(key: key, value: value)
                state.l3 = value
            case .buttonThumbR:
                guard state.r3 != value else { break }
                delegate?.toggle(key: key, value: value)
                state.r3 = value
                
            case .buttonSelect:
                guard state.select != value else { break }
                delegate?.toggle(key: key, value: value)
                state.select = value
            case .buttonStart:
                guard state.start != value else { break }
                delegate?.toggle(key: key, value: value)
                state.start = value
            case .buttonMode:
                guard state.mode != value else { break }
                delegate?.toggle(key: key, value: value)
                state.mode = value
                
            default:
                let state = KeyEventMetaState(event: event)
                print("keyboard:", key, state, flags, action)
            }
        }
    }
    
    private func joystick(
        app: UnsafeMutablePointer<android_app>,
        type: InputEventType,
        event: OpaquePointer?
    ) throws {
        guard type == .motion else {
            throw NativeActivityInputError.joystickType
        }
        let action = AMotionEvent_getAction(event)
        let pointer = pointer(action: action)
        guard let action = MotionEventAction(action: action) else {
            throw NativeActivityInputError.joystickMotion
        }
        guard action == .move else { return }
        
        let lTrigger = value(axis: .lTrigger, event: event, pointer: pointer)
        let rTrigger = value(axis: .rTrigger, event: event, pointer: pointer)
        
        if state.lTrigger != lTrigger {
            delegate?.leftTrigger(value: lTrigger)
            state.lTrigger = lTrigger
        }
        
        if state.rTrigger != rTrigger {
            delegate?.rightTrigger(value: rTrigger)
            state.rTrigger = rTrigger
        }
        
        let dpadX = value(axis: .hatX, event: event, pointer: pointer)
        let dpadY = value(axis: .hatY, event: event, pointer: pointer)
        
        if state.dpadX != dpadX || state.dpadY != dpadY {
            let up = dpadY < 0
            let down = dpadY > 0
            let left = dpadX < 0
            let right = dpadX > 0
            
            if state.up != up {
                delegate?.toggle(key: .dpadUp, value: up)
                state.up = up
            }
            
            if state.down != down {
                delegate?.toggle(key: .dpadDown, value: down)
                state.down = down
            }
            
            if state.left != left {
                delegate?.toggle(key: .dpadLeft, value: left)
                state.left = left
            }
            
            if state.right != right {
                delegate?.toggle(key: .dpadRight, value: right)
                state.right = right
            }
            
            delegate?.dpad(x: dpadX, y: dpadY)
            state.dpadX = dpadX
            state.dpadY = dpadY
        }
        
        let lThumbstickX = value(axis: .x, event: event, pointer: pointer)
        let lThumbstickY = value(axis: .y, event: event, pointer: pointer)
        
        let rThumbstickX = value(axis: .z, event: event, pointer: pointer)
        let rThumbstickY = value(axis: .rz, event: event, pointer: pointer)
        
        if state.lThumbstickX != lThumbstickX || state.lThumbstickY != lThumbstickY {
            delegate?.leftThumbstick(x: lThumbstickX, y: lThumbstickY)
            state.lThumbstickX = lThumbstickX
            state.lThumbstickY = lThumbstickY
        }
        
        if state.rThumbstickX != rThumbstickX || state.rThumbstickY != rThumbstickY {
            delegate?.rightThumbstick(x: rThumbstickX, y: rThumbstickY)
            state.rThumbstickX = rThumbstickX
            state.rThumbstickY = rThumbstickY
        }
    }
    
    private func touchscreen(
        app: UnsafeMutablePointer<android_app>,
        type: InputEventType,
        event: OpaquePointer?
    ) throws {
        guard type == .motion else {
            throw NativeActivityInputError.touchscreenType
        }
        guard let action = MotionEventAction(event: event) else {
            throw NativeActivityInputError.touchscreenValue
        }
        let count = AMotionEvent_getPointerCount(event)
        let touches: [(id: CInt, x: Float, y: Float, pressure: Float)] = (0..<count).map({ i in
            let id = AMotionEvent_getPointerId(event, i)
            let x = AMotionEvent_getX(event, i)
            let y = AMotionEvent_getY(event, i)
            let pressure = AMotionEvent_getPressure(event, i)
            return (id, x, y, pressure)
        })
        let window = app.pointee.window
        
        switch action {
        case .down:
            delegate?.touchesBegan(window: window, touches: touches)
        case .up:
            delegate?.touchesEnded(window: window, touches: touches)
        case .move:
            delegate?.touchesMoved(window: window, touches: touches)
        case .cancel:
            delegate?.touchesCancelled(window: window, touches: touches)
        default: break
        }
    }
    
    private func mouse(
        app: UnsafeMutablePointer<android_app>,
        type: InputEventType,
        event: OpaquePointer?
    ) throws {
        switch type {
        case .key:
            guard KeyEventAction(event: event) != nil,
                  KeyEventCode(event: event) != nil else {
                throw NativeActivityInputError.mouseKey
            }
            
            throw NativeActivityInputError.unspecifiedSource
            
        case .motion:
            let action = AMotionEvent_getAction(event)
            let pointer = pointer(action: action)
            guard let action = MotionEventAction(action: action) else {
                throw NativeActivityInputError.mouseMotion
            }
            
            let x = AMotionEvent_getX(event, pointer)
            let y = AMotionEvent_getY(event, pointer)
            let window = app.pointee.window
            
            switch action {
            case .buttonPress:
                let button = MotionEventButton(event: event)
                guard let index = index(for: button) else { break }
                delegate?.mouseDown(window: window, x: x, y: y, index: index)
            case .buttonRelease, .cancel:
                let button = MotionEventButton(event: event)
                guard let index = index(for: button) else { break }
                delegate?.mouseUp(window: window, x: x, y: y, index: index)
            case .move:
                let button = MotionEventButton(state: event)
                guard let index = index(for: button) else { break }
                delegate?.mouseDragged(window: window, x: x, y: y, index: index)
            case .hoverMove:
                delegate?.mouseMoved(window: window, x: x, y: y)
            case .scroll:
                let horizontal = value(axis: .hScroll, event: event, pointer: pointer)
                let vertical = value(axis: .vScroll, event: event, pointer: pointer)
                delegate?.mouseScroll(window: window, x: x, y: y, vertical: vertical, horizontal: horizontal)
            case .down, .up, .hoverEnter, .hoverExit:
                break
            default:
                throw NativeActivityInputError.unspecifiedSource
            }
        default: break
        }
    }
}

private enum NativeActivityInputError: String, Error {
    //unexpected behaviour
    case keyboardType
    case keyboardValue
    case touchscreenType
    case touchscreenValue
    case mouseKey
    case mouseMotion
    case joystickType
    case joystickMotion
    
    //consciously ignored
    case unspecifiedSource
    
    //unavailable source
    case unhandledEvent
}

private struct ControllerState {
    var a: Bool = false
    var b: Bool = false
    var x: Bool = false
    var y: Bool = false
    
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    
    var dpadX: Float = 0.0
    var dpadY: Float = 0.0
    
    var l1: Bool = false
    var r1: Bool = false
    var l2: Bool = false
    var r2: Bool = false
    var l3: Bool = false
    var r3: Bool = false
    
    var lTrigger: Float = 0.0
    var rTrigger: Float = 0.0
    
    var lThumbstickX: Float = 0.0
    var lThumbstickY: Float = 0.0
    var rThumbstickX: Float = 0.0
    var rThumbstickY: Float = 0.0
    
    var select: Bool = false
    var start: Bool = false
    var mode: Bool = false
}

private struct Handler {
    let handle_cmd: (UnsafeMutablePointer<android_app>?, CInt) -> Void
    let handle_input: (UnsafeMutablePointer<android_app>?, OpaquePointer?) -> CInt
    
    init(
        handle_cmd: @escaping (UnsafeMutablePointer<android_app>?, CInt) -> Void,
        handle_input: @escaping (UnsafeMutablePointer<android_app>?, OpaquePointer?) -> CInt
    ) {
        self.handle_cmd = handle_cmd
        self.handle_input = handle_input
    }
}

private func onAppCmd(app: UnsafeMutablePointer<android_app>!, cmd: CInt) {
    app.pointee.userData.load(as: Handler.self).handle_cmd(app, cmd)
}

private func onInputEvent(app: UnsafeMutablePointer<android_app>!, event: OpaquePointer?) -> CInt {
    app.pointee.userData.load(as: Handler.self).handle_input(app, event)
}

private extension ApplicationCommand {
    func handle_cmd(app: UnsafeMutablePointer<android_app>!, cmd: CInt) {
        switch Int(cmd) {
        case APP_CMD_CONFIG_CHANGED:
            configurationChanged(app: app)
            
        case APP_CMD_SAVE_STATE:
            saveState(app: app)
            
        case APP_CMD_START:
            start(app: app)
            
        case APP_CMD_STOP:
            stop(app: app)
            
        case APP_CMD_RESUME:
            resume(app: app)
            
        case APP_CMD_PAUSE:
            pause(app: app)
            
        case APP_CMD_DESTROY:
            destroy(app: app)
            
        case APP_CMD_LOW_MEMORY:
            lowMemory(app: app)
            
        case APP_CMD_GAINED_FOCUS:
            gainedFocus(app: app)
            
        case APP_CMD_LOST_FOCUS:
            lostFocus(app: app)
            
        case APP_CMD_CONTENT_RECT_CHANGED:
            contentRectChanged(app: app)
            
        case APP_CMD_INIT_WINDOW:
            initializeWindow(app: app)
            
        case APP_CMD_TERM_WINDOW:
            terminateWindow(app: app)
            
        case APP_CMD_WINDOW_RESIZED:
            windowResized(app: app)
            
        case APP_CMD_WINDOW_REDRAW_NEEDED:
            windowRedrawNeeded(app: app)
            
        case APP_CMD_INPUT_CHANGED:
            inputChanged(app: app)
            
        default:
            android_log(priority: .error, tag: "threaded_app", message: "event not handled: \(cmd)")
        }
    }
}

private extension ApplicationInput {
    func handle_input(app: UnsafeMutablePointer<android_app>!, event: OpaquePointer?) -> CInt {
        do {
            try input(app: app, event: event)
            return 1
        } catch {
            android_log(priority: .error, tag: "threaded_app", message: "\(error)")
            return 0
        }
    }
}

private extension NativeActivity {
    func index(for button: MotionEventButton) -> Int? {
        switch button {
        case .primary: return 0
        case .secondary: return 1
        case .tertiary: return 2
        default: return nil
        }
    }
    
    func value(axis: MotionEventAxis, event: OpaquePointer?, pointer: Int) -> Float {
        AMotionEvent_getAxisValue(event, axis.rawValue, pointer)
    }
    
    func pointer(action: CInt) -> Int {
        (Int(action) & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT
    }
}

private extension MotionEventButton {
    init(event: OpaquePointer?) {
        self.init(rawValue: AMotionEvent_getActionButton(event))
    }
    
    init(state event: OpaquePointer?) {
        self.init(rawValue: AMotionEvent_getButtonState(event))
    }
}

private extension MotionEventAction {
    init?(event: OpaquePointer?) {
        self.init(action: AMotionEvent_getAction(event))
    }
    
    init?(action: CInt) {
        self.init(rawValue: action & CInt(AMOTION_EVENT_ACTION_MASK))
    }
}

private extension KeyEventAction {
    init?(event: OpaquePointer?) {
        self.init(rawValue: AKeyEvent_getAction(event))
    }
}

private extension KeyEventCode {
    init?(event: OpaquePointer?) {
        self.init(rawValue: AKeyEvent_getKeyCode(event))
    }
}

private extension KeyEventMetaState {
    init(event: OpaquePointer?) {
        self.init(rawValue: AKeyEvent_getMetaState(event))
    }
}

private extension KeyEventFlags {
    init(event: OpaquePointer?) {
        self.init(rawValue: AKeyEvent_getFlags(event))
    }
}

private extension InputEventType {
    init?(event: OpaquePointer?) {
        self.init(rawValue: AInputEvent_getType(event))
    }
}

private extension InputEventSource {
    init?(event: OpaquePointer?) {
        self.init(rawValue: AInputEvent_getSource(event))
    }
}

private extension InputEventTool {
    init?(event: OpaquePointer?, pointer: Int) {
        self.init(rawValue: AMotionEvent_getToolType(event, pointer))
    }
}
