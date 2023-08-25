//
//  Strings.swift
//  Localization
//
//  Created by aydar.media on 12.08.2023.
//

import Foundation

fileprivate let currentLocale = Locale.current.identifier

public struct LocalizedString: CustomStringConvertible {
    let en: String
    let ru: String
    
    public init(en: String, ru: String) {
        self.en = en
        self.ru = ru
    }
    
    public var description: String {
        switch currentLocale {
        case "ru_RU":
            return self.ru
        default:
            return self.en
        }
    }
}

public struct Strings {
    public static let welcomeMessage = LocalizedString(
        en: "Launching Cassiopeia...",
        ru: "Запуск Cassiopeia..."
    )
    public static let checkingKeychainMessage = LocalizedString(
        en: "Checking keychain...",
        ru: "Проверка связки ключей..."
    )
    public static let keychainEntityNotFoundFailureMessage = LocalizedString(
        en: "Entity not found in keychain",
        ru: "Ключ не найден в связке ключей"
    )
    public static let necessaryKeychainEntitiesNotFoundFatalErrorMessage = LocalizedString(
        en: "Necessary tokens not found in keychain",
        ru: "Необходимые ключи отсутствуют в связке"
    )
    public static let necessaryKeychainEntityNotFoundMessage = LocalizedString(
        en: "Necessary token not found in keychain",
        ru: "Необходимый ключ отсутствуют в связке"
    )
    public static let genericValuePrompt = LocalizedString(
        en: "Enter it",
        ru: "Внесите его"
    )
    public static let genericWritingMessage = LocalizedString(
        en: "Writing",
        ru: "Запись"
    )
    public static let successResultLabel = LocalizedString(
        en: "[OKAY]",
        ru: "[УСПЕХ]"
    )
    public static let failureResultLabel = LocalizedString(
        en: "[FAIL]",
        ru: "[ОШИБКА]"
    )
    public static let warningResultLabel = LocalizedString(
        en: "[WARN]",
        ru: "[ВНИМАНИЕ]"
    )
    public static let fatalErrorLabel = LocalizedString(
        en: "FATAL",
        ru: "КРИТИЧ"
    )
}
