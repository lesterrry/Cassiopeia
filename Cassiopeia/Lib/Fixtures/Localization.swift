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
    
    var every: [String] {
        return [en, ru]
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
    public static let checkingAuthTokenMessage = LocalizedString(
        en: "Checking auth token",
        ru: "Проверка токена"
    )
    public static let AuthMessage = LocalizedString(
        en: "Authorizing",
        ru: "Авторизация"
    )
    public static let keychainEntityNotFoundFailureMessage = LocalizedString(
        en: "Entity not found in keychain",
        ru: "Ключ не найден в связке ключей"
    )
    public static let necessaryKeychainEntitiesNotFoundFatalErrorMessage = LocalizedString(
        en: "Necessary tokens not found in keychain",
        ru: "Необходимые ключи отсутствуют в связке"
    )
    public static let necessaryKeychainEntityNotFoundDialogMessage = LocalizedString(
        en: "Necessary token not found in keychain",
        ru: "Необходимый ключ отсутствуют в связке"
    )
    public static let authTokenDialogPrompt = LocalizedString(
        en: "Do you want to authorize?",
        ru: "Хотите авторизоваться?"
    )
    public static let authTokenNotFoundWarningMessage = LocalizedString(
        en: "Auth token not found",
        ru: "Токен авторизации отсутствует"
    )
    public static let genericValuePrompt = LocalizedString(
        en: "Enter it",
        ru: "Внесите его"
    )
    public static let genericLoginPrompt = LocalizedString(
        en: "Enter login",
        ru: "Введите логин"
    )
    public static let genericPasswordPrompt = LocalizedString(
        en: "Enter password",
        ru: "Введите пароль"
    )
    public static let modalExplicitResponsePrompt = LocalizedString(
        en: "Please state explicitly: '\(modalYesLabel.en)' or '\(modalNoLabel.en)'",
        ru: "Пожалуйста, ответьте явно: '\(modalYesLabel.ru)' или '\(modalNoLabel.ru)'"
    )
    public static let genericWritingMessage = LocalizedString(
        en: "Writing",
        ru: "Запись"
    )
    public static let modalYesLabel = LocalizedString(
        en: "yes",
        ru: "да"
    )
    public static let modalNoLabel = LocalizedString(
        en: "no",
        ru: "нет"
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
