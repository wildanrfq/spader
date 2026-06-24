// Core/i18n/LanguageManager.swift
import Foundation
internal import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published private(set) var strings: AppStrings

    private let key = "app_language"

    var currentLanguage: String {
        UserDefaults.standard.string(forKey: key) ?? "ID"
    }

    private init() {
        let lang = UserDefaults.standard.string(forKey: "app_language") ?? "ID"
        strings = lang == "EN" ? EnglishStrings : IndonesianStrings
    }

    func setLanguage(_ lang: String) {
        UserDefaults.standard.set(lang, forKey: key)
        strings = lang == "EN" ? EnglishStrings : IndonesianStrings
    }
}
