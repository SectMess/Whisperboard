import AppDevUtils
import Combine
import ComposableArchitecture
import Dependencies
import Foundation

// MARK: - SettingsClient

struct SettingsClient {
  var settingsPublisher: @Sendable () -> AnyPublisher<Settings, Error>
  var settings: @Sendable () -> Settings
  var updateSettings: @Sendable (Settings) async throws -> Void
}

extension SettingsClient {
  func setValue<Value: Codable>(_ value: Value, forKey keyPath: WritableKeyPath<Settings, Value>) async throws {
    var settings = settings()
    settings[keyPath: keyPath] = value
    try await updateSettings(settings)
  }
}

// MARK: DependencyKey

extension SettingsClient: DependencyKey {
  static var liveValue: Self = {
    let docURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let settingsURL = docURL.appendingPathComponent("settings.json")
    let settingsSubject = CodableValueSubject<Settings>(fileURL: settingsURL)

    return Self(
      settingsPublisher: { settingsSubject.eraseToAnyPublisher() },
      settings: { settingsSubject.value ?? Settings() },
      updateSettings: { settings in settingsSubject.send(settings) }
    )
  }()
}

extension DependencyValues {
  var settings: SettingsClient {
    get { self[SettingsClient.self] }
    set { self[SettingsClient.self] = newValue }
  }
}
