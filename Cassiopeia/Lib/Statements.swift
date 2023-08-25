//
//  Statements.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Darwin.C
import Rainbow
import Constellation

typealias TokenCollection = [KeychainEntity.Account : String?]

enum Statement {
    case line(String, Color? = nil)
    case space(Int = 1)
    case operation(String, Int = 1)
    case operationResult(OperationResult, Int = 1)
    case fatalError(String)
    case input(String, Bool = false, Int = 1)
    case linebreak
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

fileprivate func write(_ string: String..., nowrap: Bool = false) {
    if string.count == 0 { print() }
    else { print(string[0], terminator: nowrap ? "" : "\n") }
    if nowrap { fflush(stdout) }
}

fileprivate func read(_ prompt: String, secret: Bool = false) -> String {
    fputs(prompt, stdout)
    fflush(stdout)

    ConsoleUtils.setEcho(on: !secret)
    let secretData = readLine(strippingNewline: true)
    ConsoleUtils.setEcho(on: true)

    if secret { print() }
    
    return secretData ?? ""
}

@discardableResult
func state(_ statement: Statement) -> String? {
    switch statement {
    case .line(let content, let color):
        write(resolveColoredString(content, color: color))
    case .space(let times):
        for _ in 1...times { write() }
    case .operation(let title, let indentLevel):
        write("\(makeIndent(indentLevel))\(title)... ", nowrap: true)
    case .operationResult(let result, let indentLevel):
        switch result.status {
        case .success: write(Strings.successResultLabel.description.applyingCodes(Color.green))
        case .failure: write(Strings.failureResultLabel.description.applyingCodes(Color.red))
        case .warning: write(Strings.warningResultLabel.description.applyingCodes(Color.yellow))
        }
        if let message = result.message { write("\(makeIndent(indentLevel))    >>> \(message)") }
    case .fatalError(let message):
        write("\(Strings.fatalErrorLabel.description): \(message)".applyingCodes(Color.red))
        exit(1)
    case .input(let prompt, let secret, let indentLevel):
        let input = read("\(makeIndent(indentLevel))\(prompt): ", secret: secret)
        return input
    case .linebreak:
        print()
    }
    return nil
}

@discardableResult
func stateKeychainCheck() -> TokenCollection {
    var tokens: TokenCollection = [:]
    for i in KeychainEntity.Account.allCases {
        state(.operation(i.rawValue))
        let result = Operation.keychainCheck(account: i.rawValue)
        state(.operationResult(result))
        tokens[i] = result.output as? String
    }
    return tokens
}

func stateFulfillTokensDialog(tokens: TokenCollection) -> TokenCollection {
    var fulfilledTokens = tokens
    for (name, value) in tokens {
        if value == nil {
            state(.line( "\(Strings.necessaryKeychainEntityNotFoundMessage.description): \(name.rawValue)" ))
            let input = state(.input(Strings.genericValuePrompt.description, true))
            state(.operation(Strings.genericWritingMessage.description, 2))
            let result = Operation.keychainPut(account: name.rawValue, value: input!)
            state(.operationResult(result))
            fulfilledTokens[name] = input
        }
    }
    return fulfilledTokens
}

@discardableResult
func stateApiClientInit(appId: String, appSecret: String) -> ApiClient {
    state(.line("Авторизация..."))
    state(.operation("Проверка токена"))
    let result = Operation.apiInit(appId: appId, appSecret: appSecret)
    state(.operationResult(result))
    return result.output as! ApiClient
}
