//
//  main.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

state(.line( Strings.welcomeMessage.description ))
state(.space())
state(.line( Strings.checkingKeychainMessage.description ))

stateKeychainCheck()
