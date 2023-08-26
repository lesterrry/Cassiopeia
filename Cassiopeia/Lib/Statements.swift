//
//  Statements.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Darwin.C
import Rainbow
import Constellation

typealias TokenCollection = [KeychainEntity.EssentialAccount : String?]

enum Statement {
    case line(String, Color? = nil)
    case space(Int = 1)
    case operation(String, Int = 0)
    case operationResult(OperationResult, Int = 1)
    case fatalError(String)
    case input(String, Bool = false, Int = 1)
    case linebreak
    case modal(String)
}

fileprivate enum ModalResponse {
    case yes
    case no
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
func state(_ statement: Statement) -> Any? {
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
        if let message = result.message { write("\(makeIndent(indentLevel))>>> \(message)") }
    case .fatalError(let message):
        write("\(Strings.fatalErrorLabel): \(message)".applyingCodes(Color.red))
        exit(1)
    case .input(let prompt, let secret, let indentLevel):
        let input = read("\(makeIndent(indentLevel))\(prompt): ", secret: secret)
        return input
    case .linebreak:
        print()
    case .modal(let prompt):
        let label = "\(Strings.modalYesLabel)/\(Strings.modalNoLabel)"
        while true {
            let response = read("\(prompt) \(label): ")
            if Strings.modalYesLabel.every.contains(response) {
                return ModalResponse.yes
            } else if Strings.modalNoLabel.every.contains(response) {
                return ModalResponse.no
            } else {
                write(Strings.modalExplicitResponsePrompt.description)
            }
        }
    }
    return nil
}

@discardableResult
func stateKeychainCheck() -> TokenCollection {
    var tokens: TokenCollection = [:]
    for i in KeychainEntity.EssentialAccount.allCases {
        state(.operation(i.rawValue, 1))
        let result = Operation.keychainCheck(account: i.rawValue)
        state(.operationResult(result, 2))
        tokens[i] = .some(result.output as? String)
    }
    return tokens
}

func stateFulfillTokensDialog(tokens: TokenCollection) -> TokenCollection {
    var fulfilledTokens = tokens
    var needsLinebreak = false
    for (name, value) in tokens {
        if value == nil {
            state(.line( "\(Strings.necessaryKeychainEntityNotFoundDialogMessage): \(name.rawValue)" ))
            let input = state(.input(Strings.genericValuePrompt.description, true))
            state(.operation(Strings.genericWritingMessage.description, 2))
            let result = Operation.keychainPut(account: name.rawValue, value: input! as! String)
            state(.operationResult(result))
            fulfilledTokens[name] = (input as! String)
            needsLinebreak = true
        }
    }
    if needsLinebreak { state(.linebreak) }
    return fulfilledTokens
}

@discardableResult
func stateApiClientInit(appId: String, appSecret: String) async -> ApiClient {
    state(.operation(Strings.checkingAuthTokenMessage.description))
    let result = Operation.apiInit(appId: appId, appSecret: appSecret)
    state(.operationResult(result))
    var client = result.output as! ApiClient
    switch result.status {
    case .success:
        state(.operation(Strings.AuthMessage.description))
        await client.auth() { result in
            switch result {
            case .success(_):
                state(.operationResult(OperationResult(.success)))
            case .failure(let error):
                state(.operationResult(OperationResult(.failure, message: "\(error)" + error.localizedDescription)))
            }
        }
        
        return client
    case .warning:
        state(.linebreak)
        let response = state(.modal(Strings.authTokenDialogPrompt.description)) as! ModalResponse
        if response == .yes {
            let login = state(.input(Strings.genericLoginPrompt.description)) as! String
            let password = state(.input(Strings.genericPasswordPrompt.description, true)) as! String
            state(.linebreak)
            state(.operation(Strings.AuthMessage.description))
            let result = await Operation.apiAuth(&client, login: login, password: password)
            state(.operationResult(result))
            switch result.status {
            case .success:
                return client
            case .failure:
                state(.fatalError(Strings.apiClientInitFailureFatalErrorMessage.description))
            case .warning:
                state(.linebreak)
                let code = state(.input(Strings.genericSMSCodePrompt.description, false, 0)) as! String
                state(.linebreak)
                state(.operation(Strings.AuthMessage.description))
                let result = await Operation.apiAuth(&client, login: login, password: password, smsCode: code)
                state(.operationResult(result))
                return client
            }
        } else {
            state(.fatalError(Strings.necessaryKeychainEntitiesNotFoundFatalErrorMessage.description))
        }
    default:
        ()
    }
    return result.output as! ApiClient
}
