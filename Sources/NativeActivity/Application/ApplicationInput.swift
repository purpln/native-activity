import NativeAppGlue

public protocol ApplicationInput {
    func input(app: UnsafeMutablePointer<android_app>, event: OpaquePointer?) throws
}

public extension ApplicationInput {
    func input(app: UnsafeMutablePointer<android_app>, event: OpaquePointer?) throws {}
}
