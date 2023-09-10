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
typealias SettingCollection = [Settings.Key : String?]

enum Statement {
    case line(String, Color? = nil, Int = 0, Bool = false)
    case indent(Int = 1)
    case operation(String, Int = 0)
    case operationResult(OperationResult, Int = 1)
    case fatalError(String)
    case input(String, Bool = false, Int = 1)
    case linebreak
    case modal(String)
    case raw(() -> ())
}

fileprivate enum ModalResponse {
    case yes
    case no
}

fileprivate func makeIndent(_ level: Int) -> String {
    return String(repeating: "    ", count: level)
}

fileprivate func resolveColoredString(_ string: String, color: Color? = nil) -> String {
    if let c = color {
        return string.applyingCodes(c)
    } else {
        return string
    }
}

fileprivate var rawIndentLevel = 0
fileprivate var rawIndentDisable = false

fileprivate func write(_ string: String? = nil, nowrap: Bool = false) {
    if string != nil {
        print(makeIndent(rawIndentDisable ? 0 : rawIndentLevel) + string!, terminator: nowrap ? "" : "\n")
    } else {
        print()
    }
    if nowrap {
        fflush(stdout)
        rawIndentDisable = true
    } else {
        rawIndentDisable = false
    }
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

func setRawIndentLevel(_ level: Int) {
    rawIndentLevel = level
}

func resetRawIndentLevel() {
    rawIndentLevel = 0
}

@discardableResult
func state(_ statement: Statement) -> Any? {
    switch statement {
    case .line(let content, let color, let indentLevel, let nowrap):
        write(makeIndent(indentLevel) + resolveColoredString(content, color: color), nowrap: nowrap)
    case .indent(let level):
        write(makeIndent(level), nowrap: true)
    case .operation(let title, let indentLevel):
        write("\(makeIndent(indentLevel))\(title)... ", nowrap: true)
    case .operationResult(let result, let indentLevel):
        switch result.status {
        case .success: write(Strings.successResultLabel.description.applyingCodes(Color.green))
        case .failure: write(Strings.failureResultLabel.description.applyingCodes(Color.red))
        case .warning: write(Strings.warningResultLabel.description.applyingCodes(Color.yellow))
        case .silence: print()
        }
        if let message = result.message { write("\(makeIndent(indentLevel))>>> \(message)") }
    case .fatalError(let message):
        write("\(Strings.fatalErrorLabel): \(message)".applyingCodes(Color.red))
        exit(1)
    case .input(let prompt, let secret, let indentLevel):
        let input = read("\(makeIndent(indentLevel))\(prompt): ", secret: secret)
        return input
    case .linebreak:
        write()
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
    case .raw(let action):
        write()
        action()
        write()
    }
    return nil
}

@discardableResult
func stateKeychainCheck() -> TokenCollection {
    var tokens: TokenCollection = [:]
    for i in (KeychainEntity.Account.allCases) {
        state(.operation(i.rawValue, 1))
        let result = Operation.keychainCheck(account: i.rawValue)
        state(.operationResult(result, 2))
        tokens[i] = .some(result.output as? String)
    }
    return tokens
}

@discardableResult
func stateSettingsCheck() -> SettingCollection {
    var settings: SettingCollection = [:]
    for i in (Settings.Key.allCases) {
        state(.operation(i.rawValue, 1))
        let result = Operation.settingCheck(key: i.rawValue)
        state(.operationResult(result, 2))
        settings[i] = .some(result.output as? String)
    }
    return settings
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
            let result = await Operation.apiAuth(client: &client, login: login, password: password)
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
                let result = await Operation.apiAuth(client: &client, login: login, password: password, smsCode: code)
                state(.operationResult(result))
                return client
            default: fatalError()
            }
        } else {
            state(.fatalError(Strings.necessaryKeychainEntitiesNotFoundFatalErrorMessage.description))
        }
    default:
        ()
    }
    return result.output as! ApiClient
}

func stateCommandAwait(client: ApiClient) async {
    let command = state(.input("", false, 0)) as! String
    if Command.allCases.contains(where: { $0.rawValue == command }) {
        state(.operation(Strings.GenericRunMessage.description))
        let result = await Operation.runCommand(Command(rawValue: command)!, client: client)
        state(.operationResult(result))
        if let action = result.output as? () -> () {
            state(.raw(action))
        }
    } else {
        state(.line(Strings.unknownCommandErrorMessage.description, Color.red))
    }
}

func stateCarMetric(title: String, value: Any?, exactValue: Any? = nil) {
    let exact = exactValue != nil ? " (\(exactValue!))" : ""
    state(.line("\(title): \(value ?? Strings.genericUnknownLabel)\(exact)"))
}

func stateCarState(_ carState: DescriptiveDevice.State?) {
    switch carState {
    case .armed:
        state(.line(Strings.carArmedLabel.description, Color.green))
    case .disarmed:
        state(.line(Strings.carDisarmedLabel.description, Color.lightWhite))
    case .running:
        state(.line(Strings.carRunningLabel.description, Color.lightRed))
    case .alarm:
        state(.line(Strings.carAlarmLabel.description, Color.red))
    case .service:
        state(.line(Strings.carServiceLabel.description, Color.yellow))
    case .stayHome:
        state(.line(Strings.carStayHomeLabel.description, Color.blue))
    case .unknown, nil:
        state(.line(Strings.carUnknownLabel.description, Color.lightWhite))
    }
}

func stateUserCars(cars: [ApiResponse.Device]) {
    for i in cars {
        state(.line("\(i.alias ?? Strings.nilValueLabel.description) (#\(i.deviceId))"))
    }
}

func stateCar(_ car: ApiResponse.Device) {
    state(.line("\(car.alias ?? Strings.nilValueLabel.description) — ", nil, 0, true))
    let descriptive = car.descriptive()
    stateCarState(descriptive.state())
    rawIndentLevel += 1
    
    stateCarMetric(title: Strings.doorsLabel.description, value: descriptive.$doorsOpen)
    stateCarMetric(title: Strings.gsmLabel.description, value: descriptive.$gsmLevel, exactValue: descriptive.gsmLevel)
    stateCarMetric(title: Strings.gpsLabel.description, value: descriptive.$gpsLevel, exactValue: descriptive.gpsLevel)
    stateCarMetric(title: Strings.batteryLabel.description, value: descriptive.batteryVoltage)
    
    resetRawIndentLevel()
}
