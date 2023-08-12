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
}

func localizedString(forKey key: String) -> String {
    let locale = Locale.current.identifier
    let language = String(locale.prefix(2))
    let localizationBundleName = "Localizable_\(language)"
    print(localizationBundleName)
    let path = CommandLine.arguments[0].components(separatedBy: "/")
    let resourceDir = path[0...path.count - 2].joined(separator: "/") + "/Resources/"
    let url = URL(fileURLWithPath: resourceDir + localizationBundleName + ".strings")

    guard let localizationDict = NSDictionary(contentsOf: url), let localizedString = localizationDict[key] as? String else {
        return key // Return the key if no localization found.
    }

    return localizedString
}

