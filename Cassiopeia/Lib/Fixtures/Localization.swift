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
    public static let checkingSettingsMessage = LocalizedString(
        en: "Checking settings...",
        ru: "Проверка настроек..."
    )
    public static let checkingAuthTokenMessage = LocalizedString(
        en: "Checking auth token",
        ru: "Проверка токена"
    )
    public static let AuthMessage = LocalizedString(
        en: "Authorizing",
        ru: "Авторизация"
    )
    public static let GenericRunMessage = LocalizedString(
        en: "Running",
        ru: "Исполнение"
    )
    public static let keychainEntityNotFoundFailureMessage = LocalizedString(
        en: "Entity not found in keychain",
        ru: "Ключ не найден в связке ключей"
    )
    public static let settingNotFoundFailureMessage = LocalizedString(
        en: "Setting not found in user defaults",
        ru: "Настройка не найдена"
    )
    public static let necessaryKeychainEntitiesNotFoundFatalErrorMessage = LocalizedString(
        en: "Necessary tokens not found in keychain",
        ru: "Необходимые ключи отсутствуют в связке"
    )
    public static let apiClientInitFailureFatalErrorMessage = LocalizedString(
        en: "Failed to initialize api client",
        ru: "Не удалось инициализировать клиент"
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
    public static let unknownCommandErrorMessage = LocalizedString(
        en: "Unknown command",
        ru: "Неизвестная команда, используйте help"
    )
    public static let secondFactorEnabledWarningMessage = LocalizedString(
        en: "2FA enabled",
        ru: "Включена двухфакторная аутентификация"
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
    public static let genericSMSCodePrompt = LocalizedString(
        en: "Enter SMS code",
        ru: "Введите код из СМС"
    )
    public static let deviceIdPrompt = LocalizedString(
        en: "Enter car ID",
        ru: "Введите ID автомобиля"
    )
    public static let modalExplicitResponsePrompt = LocalizedString(
        en: "Please state explicitly: '\(modalYesLabel.en)' or '\(modalNoLabel.en)'",
        ru: "Пожалуйста, ответьте явно: '\(modalYesLabel.ru)' или '\(modalNoLabel.ru)'"
    )
    public static let readyForInputMessage = LocalizedString(
        en: "Awaiting commands",
        ru: "Готов к командам"
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
    public static let nilValueLabel = LocalizedString(
        en: "<nil>",
        ru: "<nil>"
    )
    public static let genericOpenLabel = LocalizedString(
        en: "ОТКР.",
        ru: "OPEN"
    )
    public static let genericClosedLabel = LocalizedString(
        en: "ЗАКР.",
        ru: "CLOSED"
    )
    public static let genericOnLabel = LocalizedString(
        en: "ВКЛ.",
        ru: "ON"
    )
    public static let genericOffLabel = LocalizedString(
        en: "ВЫКЛ.",
        ru: "OFF"
    )
    public static let genericYesLabel = LocalizedString(
        en: "ДА",
        ru: "YES"
    )
    public static let genericNoLabel = LocalizedString(
        en: "НЕТ",
        ru: "NO"
    )
    public static let brokenPerimeterLabel = LocalizedString(
        en: "BROKEN",
        ru: "НАРУШ."
    )
    public static let genericUnknownLabel = LocalizedString(
        en: "UNKNOWN",
        ru: "НЕИЗВ."
    )
}
