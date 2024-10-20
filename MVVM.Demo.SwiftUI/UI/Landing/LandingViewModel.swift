//
//  LandingViewModel.swift
//  MVVM.Demo.SwiftUI
//
//  Created by Jason Lew-Rapai on 11/15/21.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

protocol LandingViewModelDelegate: AnyObject {
  func landingViewModelDidTapPulse(_ source: LandingViewModel)
  func landingViewModelDidTapSignIn(_ source: LandingViewModel)
  func landingViewModelDidTapInfiniteCards(_ source: LandingViewModel)
  func landingViewModelDidTapColorWizard(_ source: LandingViewModel)
}

@Observable
class LandingViewModel: ViewModel {
  private let alertService: AlertServiceProtocol
  private let authenticationService: AuthenticationServiceProtocol
  private let colorService: ColorServiceProtocol
  
  private weak var delegate: LandingViewModelDelegate?
  
  var todos = [Todo]()

      private var db = Firestore.firestore()

      func getAllData() {
          db.collection("todos").addSnapshotListener { (querySnapshot, error) in
              guard let documents = querySnapshot?.documents else {
                  print("No documents")
                  return
              }

              self.todos = documents.map { (queryDocumentSnapshot) -> Todo in
                  let data = queryDocumentSnapshot.data()
                  let name = data["name"] as? String ?? ""
                  return Todo(name: name)
              }
          }
      }

      func addNewData(name: String) {
             do {
                 _ = try db.collection("todos").addDocument(data: ["name": name])
             }
             catch {
                 print(error.localizedDescription)
             }
         }
  
  var isAuthenticated: AnyPublisher<Bool, Never> { self.authenticationService.isAuthenticated }
  var username: AnyPublisher<String, Never> {
    self.authenticationService.user.map { $0?.username ?? .empty }.eraseToAnyPublisher()
  }
  let pulseColor: AnyPublisher<ColorModel, Never>
  
  let pulse: PassthroughSubject<Void, Never> = PassthroughSubject()
  let signInOrOut: PassthroughSubject<Void, Never> = PassthroughSubject()
  let infiniteCards: PassthroughSubject<Void, Never> = PassthroughSubject()
  let colorWizard: PassthroughSubject<Void, Never> = PassthroughSubject()
  
  private var cancelBag: CancelBag!
  
  init(alertService: AlertServiceProtocol, authenticationService: AuthenticationServiceProtocol, colorService: ColorServiceProtocol) {
    self.alertService = alertService
    self.authenticationService = authenticationService
    self.colorService = colorService
    
    self.pulseColor = self.colorService.generateColors().share(replay: 1).eraseToAnyPublisher()
  }
  
  func setup(delegate: LandingViewModelDelegate) -> Self {
    self.delegate = delegate
    bind()
    return self
  }
  
  private func bind() {
    self.cancelBag = CancelBag()
    
    let alertService = self.alertService
    let authenticationService = self.authenticationService
    
    self.pulse
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapPulse(self)
      })
      .store(in: &self.cancelBag)
    
    self.signInOrOut
      .withLatestFrom(self.isAuthenticated)
      .sink { [weak self] isAuthenticated in
        guard let self = self else { return }
        if isAuthenticated {
          alertService.present(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            primaryButton: .destructive("Yes, sign out") {
              authenticationService.signOutAsync()
            },
            secondaryButton: .cancel())
        } else {
          self.delegate?.landingViewModelDidTapSignIn(self)
        }
      }
      .store(in: &self.cancelBag)
    
    self.infiniteCards
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapInfiniteCards(self)
      })
      .store(in: &self.cancelBag)
    
    self.colorWizard
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapColorWizard(self)
      })
      .store(in: &self.cancelBag)
  }
}

extension LandingViewModel {
  enum AuthAction {
    case signIn
    case willSignOut
  }
}
