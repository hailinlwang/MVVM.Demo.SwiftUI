//
//  MVVM_Demo_SwiftUIApp.swift
//  MVVM.Demo.SwiftUI
//
//  Created by Jason Lew-Rapai on 11/15/21.
//

import SwiftUI
import BusyIndicator
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

private let appAssembler: AppAssembler = AppAssembler()

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    
    
    
    return true
  }
}


@main
struct MVVM_Demo_SwiftUIApp: App {
  
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      AppRootCoordinatorView(
        coordinator: appAssembler.resolver.resolved(AppRootCoordinator.self)
      )
      .alertManager(appAssembler.resolver.resolved(AlertManager.self))
      .busyIndicator(appAssembler.resolver.resolved(BusyIndicatorServiceProtocol.self).busyIndicator)
    }
  }
}
