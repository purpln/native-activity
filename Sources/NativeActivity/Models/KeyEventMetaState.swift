public struct KeyEventMetaState: OptionSet {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension KeyEventMetaState {
    static let alt        = KeyEventMetaState(rawValue: 1 << 1)  //AMETA_ALT_ON
    static let altLeft    = KeyEventMetaState(rawValue: 1 << 4)  //AMETA_ALT_LEFT_ON
    static let altRight   = KeyEventMetaState(rawValue: 1 << 5)  //AMETA_ALT_RIGHT_ON
    static let shift      = KeyEventMetaState(rawValue: 1 << 0)  //AMETA_SHIFT_ON
    static let shiftLeft  = KeyEventMetaState(rawValue: 1 << 6)  //AMETA_SHIFT_LEFT_ON
    static let shiftRight = KeyEventMetaState(rawValue: 1 << 7)  //AMETA_SHIFT_RIGHT_ON
    static let sym        = KeyEventMetaState(rawValue: 1 << 2)  //AMETA_SYM_ON
    static let function   = KeyEventMetaState(rawValue: 1 << 3)  //AMETA_FUNCTION_ON
    static let ctrl       = KeyEventMetaState(rawValue: 1 << 12) //AMETA_CTRL_ON
    static let ctrlLeft   = KeyEventMetaState(rawValue: 1 << 13) //AMETA_CTRL_LEFT_ON
    static let ctrlRight  = KeyEventMetaState(rawValue: 1 << 14) //AMETA_CTRL_RIGHT_ON
    static let meta       = KeyEventMetaState(rawValue: 1 << 16) //AMETA_META_ON
    static let metaLeft   = KeyEventMetaState(rawValue: 1 << 17) //AMETA_META_LEFT_ON
    static let metaRight  = KeyEventMetaState(rawValue: 1 << 18) //AMETA_META_RIGHT_ON
    static let capsLock   = KeyEventMetaState(rawValue: 1 << 20) //AMETA_CAPS_LOCK_ON
    static let numLock    = KeyEventMetaState(rawValue: 1 << 21) //AMETA_NUM_LOCK_ON
    static let scrollLock = KeyEventMetaState(rawValue: 1 << 22) //AMETA_SCROLL_LOCK_ON
}
