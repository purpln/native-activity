import NativeAppGlue

@MainActor
protocol ApplicationCommand {
    func configurationChanged(app: UnsafeMutablePointer<android_app>)
    func saveState(app: UnsafeMutablePointer<android_app>)
    func start(app: UnsafeMutablePointer<android_app>)
    func stop(app: UnsafeMutablePointer<android_app>)
    func resume(app: UnsafeMutablePointer<android_app>)
    func pause(app: UnsafeMutablePointer<android_app>)
    func destroy(app: UnsafeMutablePointer<android_app>)
    func lowMemory(app: UnsafeMutablePointer<android_app>)
    func gainedFocus(app: UnsafeMutablePointer<android_app>)
    func lostFocus(app: UnsafeMutablePointer<android_app>)
    func contentRectChanged(app: UnsafeMutablePointer<android_app>)
    func initializeWindow(app: UnsafeMutablePointer<android_app>)
    func terminateWindow(app: UnsafeMutablePointer<android_app>)
    func windowResized(app: UnsafeMutablePointer<android_app>)
    func windowRedrawNeeded(app: UnsafeMutablePointer<android_app>)
    func inputChanged(app: UnsafeMutablePointer<android_app>)
}

extension ApplicationCommand {
    func configurationChanged(app: UnsafeMutablePointer<android_app>) {}
    func saveState(app: UnsafeMutablePointer<android_app>) {}
    func start(app: UnsafeMutablePointer<android_app>) {}
    func stop(app: UnsafeMutablePointer<android_app>) {}
    func resume(app: UnsafeMutablePointer<android_app>) {}
    func pause(app: UnsafeMutablePointer<android_app>) {}
    func destroy(app: UnsafeMutablePointer<android_app>) {}
    func lowMemory(app: UnsafeMutablePointer<android_app>) {}
    func gainedFocus(app: UnsafeMutablePointer<android_app>) {}
    func lostFocus(app: UnsafeMutablePointer<android_app>) {}
    func contentRectChanged(app: UnsafeMutablePointer<android_app>) {}
    func initializeWindow(app: UnsafeMutablePointer<android_app>) {}
    func terminateWindow(app: UnsafeMutablePointer<android_app>) {}
    func windowResized(app: UnsafeMutablePointer<android_app>) {}
    func windowRedrawNeeded(app: UnsafeMutablePointer<android_app>) {}
    func inputChanged(app: UnsafeMutablePointer<android_app>) {}
}
