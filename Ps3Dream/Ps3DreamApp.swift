// Ps3Dream iOS - Main App Entry Point

import UIKit

@main
class Ps3DreamApp: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize the emulator manager
        _ = EmulatorManager.shared
        _ = AppSettings.shared

        // Try to enable JIT on launch
        ios_enable_jit()

        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: GameListViewController())
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationBar.barStyle = .black
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if ps3dream_is_running() {
            ps3dream_pause()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if ps3dream_is_paused() {
            ps3dream_resume()
        }
    }
}
