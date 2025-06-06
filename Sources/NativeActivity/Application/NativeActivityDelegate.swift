import Android

public protocol NativeActivityDelegate: AnyObject {
    func launch()
    func destroy()
    func back()
    func animate()
    func active(window: OpaquePointer?)
    func resign(window: OpaquePointer?)
    func foreground(window: OpaquePointer?)
    func background(window: OpaquePointer?)
    func initialize(window: OpaquePointer?)
    func terminate(window: OpaquePointer?)
    func layout(window: OpaquePointer?, width: CInt, height: CInt)
    func touchesBegan(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesMoved(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesEnded(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
    func touchesCancelled(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)])
}

public extension NativeActivityDelegate {
    func launch() {}
    func destroy() {}
    func back() {}
    func animate() {
        usleep(1000)
    }
    func active(window: OpaquePointer?) {}
    func resign(window: OpaquePointer?) {}
    func foreground(window: OpaquePointer?) {}
    func background(window: OpaquePointer?) {}
    func initialize(window: OpaquePointer?) {}
    func terminate(window: OpaquePointer?) {}
    func layout(window: OpaquePointer?, width: CInt, height: CInt) {}
    func touchesBegan(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    func touchesMoved(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    func touchesEnded(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
    func touchesCancelled(window: OpaquePointer?, touches: [(id: CInt, x: Float, y: Float, pressure: Float)]) {}
}
