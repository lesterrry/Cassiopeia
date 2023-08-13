//
//  Statements.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Darwin.C
import Rainbow
import Constellation

enum Statement {
    case line(String, Color? = nil)
    case space(Int8 = 1)
    case operation(String, Int = 1)
    case operationResult(OperationResult, Int = 1)
    case fatalError(String)
}

fileprivate func makeIndent(_ times: Int) -> String {
    return String(repeating: "    ", count: times)
}

fileprivate func resolveColoredString(_ string: String, color: Color? = nil) -> String {
    if let c = color {
        return string.applyingCodes(c)
    } else {
        return string
    }
}

fileprivate func out(_ string: String..., nowrap: Bool = false) {
    if string.count == 0 { print() }
    else { print(string[0], terminator: nowrap ? "" : "\n") }
    if nowrap { fflush(stdout) }
}

func state(_ statement: Statement) {
    switch statement {
    case .line(let content, let color):
        out(resolveColoredString(content, color: color))
    case .space(let times):
        for _ in 1...times { out() }
    case .operation(let title, let indent):
        out("\(makeIndent(indent))\(title)... ", nowrap: true)
    case .operationResult(let result, let indent):
        switch result.status {
        case .success: out(Strings.successResultLabel.description.applyingCodes(Color.green))
        case .failure: out(Strings.failureResultLabel.description.applyingCodes(Color.red))
        case .warning: out(Strings.warningResultLabel.description.applyingCodes(Color.yellow))
        }
        if let message = result.message { out("\(makeIndent(indent))    >>> \(message)") }
    case .fatalError(let message):
        out("\(Strings.fatalErrorLabel.description): \(message)".applyingCodes(Color.red))
        exit(1)
    }
}

@discardableResult
func stateKeychainCheck() -> [KeychainEntity.Account : String] {
    var tokens: [KeychainEntity.Account : String] = [:]
    for i in KeychainEntity.Account.allCases {
        state(.operation(i.rawValue))
        let result = Operation.keychainCheck(account: i.rawValue)
        state(.operationResult(result))
        tokens[i] = result.output as? String
    }
    return tokens
}

@discardableResult
func stateApiClientInit(appId: String, appSecret: String) -> ApiClient {
    state(.line("Авторизация..."))
    state(.operation("Проверка токена"))
    let result = Operation.apiInit(appId: appId, appSecret: appSecret)
    state(.operationResult(result))
    return result.output as! ApiClient
}
