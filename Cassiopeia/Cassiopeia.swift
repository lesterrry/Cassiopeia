//
//  Cassiopeia.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Constellation
import Foundation

@main
struct Main {
    static func main() async {
        state(.line( Strings.welcomeMessage.description ))
        state(.linebreak)
        state(.line( Strings.checkingKeychainMessage.description ))

        var tokens = stateKeychainCheck()
        state(.line( Strings.checkingSettingsMessage.description ))
        stateSettingsCheck()

        state(.linebreak)
        tokens = stateFulfillTokensDialog(tokens: tokens)

        guard tokens[.appId] != nil && tokens[.appSecret] != nil else { state(.fatalError(Strings.necessaryKeychainEntitiesNotFoundFatalErrorMessage.description)); exit(1) }

        let client = await stateApiClientInit(appId: tokens[.appId]!!, appSecret: tokens[.appSecret]!!)
        
        state(.linebreak)
        state(.line(Strings.readyForInputMessage.description))
        
        repeat {
            await stateCommandAwait(client: client)
        } while true
        
    }
}
