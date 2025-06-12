import NativeAppGlue

public enum InputEventSource: Equatable, Hashable, Sendable {
    case unknown         //AINPUT_SOURCE_UNKNOWN
    case keyboard        //AINPUT_SOURCE_KEYBOARD
    case dpad            //AINPUT_SOURCE_DPAD
    case gamepad         //AINPUT_SOURCE_GAMEPAD
    case touchscreen     //AINPUT_SOURCE_TOUCHSCREEN
    case mouse           //AINPUT_SOURCE_MOUSE
    case stylus          //AINPUT_SOURCE_STYLUS
    case bluetoothStylus //AINPUT_SOURCE_BLUETOOTH_STYLUS
    case trackball       //AINPUT_SOURCE_TRACKBALL
    case mouseRelative   //AINPUT_SOURCE_MOUSE_RELATIVE
    case touchpad        //AINPUT_SOURCE_TOUCHPAD
    case touchNavigation //AINPUT_SOURCE_TOUCH_NAVIGATION
    case joystick        //AINPUT_SOURCE_JOYSTICK
    case hdmi            //AINPUT_SOURCE_HDMI
    case sensor          //AINPUT_SOURCE_SENSOR
    case rotaryEncoder   //AINPUT_SOURCE_ROTARY_ENCODER
    case none            //AINPUT_SOURCE_CLASS_NONE
}

public extension InputEventSource {
    init?(rawValue: CInt) {
        switch UInt32(rawValue) {
        case 0x00000000: self = .unknown
        case let event where (event & AINPUT_SOURCE_KEYBOARD)         == AINPUT_SOURCE_KEYBOARD:         self = .keyboard
        case let event where (event & AINPUT_SOURCE_DPAD)             == AINPUT_SOURCE_DPAD:             self = .dpad
        case let event where (event & AINPUT_SOURCE_GAMEPAD)          == AINPUT_SOURCE_GAMEPAD:          self = .gamepad
        case let event where (event & AINPUT_SOURCE_TOUCHSCREEN)      == AINPUT_SOURCE_TOUCHSCREEN:      self = .touchscreen
        case let event where (event & AINPUT_SOURCE_MOUSE)            == AINPUT_SOURCE_MOUSE:            self = .mouse
        case let event where (event & AINPUT_SOURCE_STYLUS)           == AINPUT_SOURCE_STYLUS:           self = .stylus
        case let event where (event & AINPUT_SOURCE_BLUETOOTH_STYLUS) == AINPUT_SOURCE_BLUETOOTH_STYLUS: self = .bluetoothStylus
        case let event where (event & AINPUT_SOURCE_TRACKBALL)        == AINPUT_SOURCE_TRACKBALL:        self = .trackball
        case let event where (event & AINPUT_SOURCE_MOUSE_RELATIVE)   == AINPUT_SOURCE_MOUSE_RELATIVE:   self = .mouseRelative
        case let event where (event & AINPUT_SOURCE_TOUCHPAD)         == AINPUT_SOURCE_TOUCHPAD:         self = .touchpad
        case let event where (event & AINPUT_SOURCE_TOUCH_NAVIGATION) == AINPUT_SOURCE_TOUCH_NAVIGATION: self = .touchNavigation
        case let event where (event & AINPUT_SOURCE_JOYSTICK)         == AINPUT_SOURCE_JOYSTICK:         self = .joystick
        case let event where (event & AINPUT_SOURCE_HDMI)             == AINPUT_SOURCE_HDMI:             self = .hdmi
        case let event where (event & AINPUT_SOURCE_SENSOR)           == AINPUT_SOURCE_SENSOR:           self = .sensor
        case let event where (event & AINPUT_SOURCE_ROTARY_ENCODER)   == AINPUT_SOURCE_ROTARY_ENCODER:   self = .rotaryEncoder
        case 0xffffff00: self = .none
        default: return nil
        }
    }
}
