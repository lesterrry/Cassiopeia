//
//  main.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Constellation

state(.line( Strings.welcomeMessage.description ))
state(.space())
state(.line( Strings.checkingKeychainMessage.description ))

let existingTokens = stateKeychainCheck()
guard
    let appId = existingTokens[KeychainEntity.Account.appId],
    let appSecret = existingTokens[KeychainEntity.Account.appSecret],
    let deviceId = existingTokens[KeychainEntity.Account.deviceId]
else {
    state(.fatalError(Strings.necessaryKeychainEntitiesNotFoundFatalErrorMessage.description)); fatalError()
}

let client = stateApiClientInit(appId: appId, appSecret: appSecret)
