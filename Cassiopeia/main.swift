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

var tokens = stateKeychainCheck()

state(.linebreak)
tokens = stateFulfillTokensDialog(tokens: tokens)

print(tokens)
//var appId = existingTokens[KeychainEntity.Account.appId]
//var appSecret = existingTokens[KeychainEntity.Account.appSecret]
//var deviceId = existingTokens[KeychainEntity.Account.deviceId]

//readSecretFromConsole(prompt: "heyy ")

//let client = stateApiClientInit(appId: appId, appSecret: appSecret)
