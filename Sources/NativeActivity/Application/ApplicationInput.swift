import NativeAppGlue

@MainActor
protocol ApplicationInput {
    func input(app: UnsafeMutablePointer<android_app>, event: OpaquePointer?) throws
}

extension ApplicationInput {
    func input(app: UnsafeMutablePointer<android_app>, event: OpaquePointer?) throws {}
}
