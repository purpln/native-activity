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
        guard let type = InputEventType(rawValue: AInputEvent_getType(event)),
              let source = InputEventSource(rawValue: AInputEvent_getSource(event)) else { return }
        
        try input(app: app, source: source, type: type, event: event)
    }
    
    func input(
        app: UnsafeMutablePointer<android_app>,
        source: InputEventSource, type: InputEventType,
        event: OpaquePointer?
    ) throws {
        switch source {
        case .keyboard:
            guard type == .key else {
                throw NativeActivityInputError.keyboardType
            }
            guard let action = KeyEventAction(rawValue: AKeyEvent_getAction(event)) else {
                throw NativeActivityInputError.keyboardValue
            }
            guard let key = KeyEventCode(rawValue: AKeyEvent_getKeyCode(event)), key != .unknown else {
                print("empty key code")
                return
            }
            let state = KeyEventMetaState(rawValue: AKeyEvent_getMetaState(event))
            let flags = KeyEventFlags(rawValue: AKeyEvent_getFlags(event))
            
            if key == .back, flags.contains(.fromSystem) {
                if action == .down {
                    delegate?.back()
                }
            } else {
                print("keyboard:", key, state, flags, action)
            }
            
        case .gamepad, .joystick, .dpad:
            let id = AInputEvent_getDeviceId(event)
            switch type {
            case .key:
                guard let action = KeyEventAction(rawValue: AKeyEvent_getAction(event)),
                      let key = KeyEventCode(rawValue: AKeyEvent_getKeyCode(event)) else {
                    throw NativeActivityInputError.gamepadKey
                }
                
                print("gamepad:", id, key, action)
                
            case .motion:
                break
            default: break
            }
            
        case .touchscreen:
            guard type == .motion else {
                throw NativeActivityInputError.touchscreenType
            }
            guard let action = MotionEventAction(rawValue: AMotionEvent_getAction(event) & CInt(AMOTION_EVENT_ACTION_MASK)) else {
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
            
        case .mouse, .mouseRelative:
            switch type {
            case .key:
                guard let action = KeyEventAction(rawValue: AKeyEvent_getAction(event)),
                      let key = KeyEventCode(rawValue: AKeyEvent_getKeyCode(event)) else {
                    throw NativeActivityInputError.mouseKey
                }
                
                print("mouse:", key, action)
                
            case .motion:
                let action = AMotionEvent_getAction(event)
                let pointer = (Int(action) & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT
                guard let action = MotionEventAction(rawValue: action & CInt(AMOTION_EVENT_ACTION_MASK)) else {
                    throw NativeActivityInputError.mouseMotion
                }
                
                //InputEventTool(rawValue: AMotionEvent_getToolType(event, pointer))
                
                func index(for button: MotionEventButton) -> Int? {
                    switch button {
                    case .primary: return 0
                    case .secondary: return 1
                    case .tertiary: return 2
                    default: return nil
                    }
                }
                
                let x = AMotionEvent_getX(event, pointer)
                let y = AMotionEvent_getY(event, pointer)
                let window = app.pointee.window
                
                switch action {
                case .buttonPress:
                    let button = MotionEventButton(rawValue: AMotionEvent_getActionButton(event))
                    guard let index = index(for: button) else { break }
                    delegate?.mouseDown(window: window, x: x, y: y, index: index)
                case .buttonRelease:
                    let button = MotionEventButton(rawValue: AMotionEvent_getActionButton(event))
                    guard let index = index(for: button) else { break }
                    delegate?.mouseUp(window: window, x: x, y: y, index: index)
                case .move:
                    let button = MotionEventButton(rawValue: AMotionEvent_getButtonState(event))
                    guard let index = index(for: button) else { break }
                    delegate?.mouseDragged(window: window, x: x, y: y, index: index)
                case .hoverMove:
                    delegate?.mouseMoved(window: window, x: x, y: y)
                case .scroll:
                    let horizontal = AMotionEvent_getAxisValue(event, MotionEventAxis.hScroll.rawValue, pointer)
                    let vertical = AMotionEvent_getAxisValue(event, MotionEventAxis.vScroll.rawValue, pointer)
                    delegate?.mouseScroll(window: window, x: x, y: y, vertical: vertical, horizontal: horizontal)
                case .down, .up, .hoverEnter, .hoverExit:
                    break
                default:
                    throw NativeActivityInputError.unspecifiedSource
                }
            default: break
            }
            
        case .any, .trackball, .touchpad, .touchNavigation, .stylus, .bluetoothStylus, .hdmi, .sensor, .rotaryEncoder:
            throw NativeActivityInputError.unspecifiedSource
        case .unknown: break
        }
    }
}

public enum NativeActivityInputError: String, Error {
    case keyboardType
    case keyboardValue
    case touchscreenType
    case touchscreenValue
    case gamepadKey
    case mouseKey
    case mouseMotion
    case unspecifiedSource
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
