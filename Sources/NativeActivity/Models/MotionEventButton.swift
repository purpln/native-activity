public struct MotionEventButton: OptionSet {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension MotionEventButton {
    static let primary         = MotionEventButton(rawValue: 1 << 0) //AMOTION_EVENT_BUTTON_PRIMARY
    static let secondary       = MotionEventButton(rawValue: 1 << 1) //AMOTION_EVENT_BUTTON_SECONDARY
    static let tertiary        = MotionEventButton(rawValue: 1 << 2) //AMOTION_EVENT_BUTTON_TERTIARY
    static let back            = MotionEventButton(rawValue: 1 << 3) //AMOTION_EVENT_BUTTON_BACK
    static let forward         = MotionEventButton(rawValue: 1 << 4) //AMOTION_EVENT_BUTTON_FORWARD
    static let stylusPrimary   = MotionEventButton(rawValue: 1 << 5) //AMOTION_EVENT_BUTTON_STYLUS_PRIMARY
    static let stylusSecondary = MotionEventButton(rawValue: 1 << 6) //AMOTION_EVENT_BUTTON_STYLUS_SECONDARY
}
