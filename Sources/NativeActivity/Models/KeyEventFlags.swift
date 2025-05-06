public struct KeyEventFlags: OptionSet {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension KeyEventFlags {
    static let wokeHere          = KeyEventFlags(rawValue: 1 << 0)  //AKEY_EVENT_FLAG_WOKE_HERE
    static let softKeyboard      = KeyEventFlags(rawValue: 1 << 1)  //AKEY_EVENT_FLAG_SOFT_KEYBOARD
    static let keepTouchMode     = KeyEventFlags(rawValue: 1 << 2)  //AKEY_EVENT_FLAG_KEEP_TOUCH_MODE
    static let fromSystem        = KeyEventFlags(rawValue: 1 << 3)  //AKEY_EVENT_FLAG_FROM_SYSTEM
    static let editorAction      = KeyEventFlags(rawValue: 1 << 4)  //AKEY_EVENT_FLAG_EDITOR_ACTION
    static let canceled          = KeyEventFlags(rawValue: 1 << 5)  //AKEY_EVENT_FLAG_CANCELED
    static let virtualHardKey    = KeyEventFlags(rawValue: 1 << 6)  //AKEY_EVENT_FLAG_VIRTUAL_HARD_KEY
    static let longPress         = KeyEventFlags(rawValue: 1 << 7)  //AKEY_EVENT_FLAG_LONG_PRESS
    static let canceledLongPress = KeyEventFlags(rawValue: 1 << 8)  //AKEY_EVENT_FLAG_CANCELED_LONG_PRESS
    static let tracking          = KeyEventFlags(rawValue: 1 << 9)  //AKEY_EVENT_FLAG_TRACKING
    static let fallback          = KeyEventFlags(rawValue: 1 << 10) //AKEY_EVENT_FLAG_FALLBACK
}
