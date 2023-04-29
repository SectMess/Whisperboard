import ComposableArchitecture
import Dependencies
import Foundation

// MARK: - BuildClient

struct BuildClient {
  var version: () -> String
  var buildNumber: () -> String
  var githubURL: () -> URL
}

// MARK: DependencyKey

extension BuildClient: DependencyKey {
  static var liveValue: Self {
    Self(
      version: { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0" },
      buildNumber: { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0" },
      githubURL: { URL(staticString: "https://github.com/SectMess/WhisperSing") }
    )
  }
}

extension DependencyValues {
  var build: BuildClient {
    get { self[BuildClient.self] }
    set { self[BuildClient.self] = newValue }
  }
}
