//
//  Statements.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Rainbow

enum Statement {
    case line(String, Color? = nil)
}

fileprivate func resolveColoredString(_ string: String, color: Color? = nil) -> String {
    if let c = color {
        return string.applyingCodes(c)
    } else {
        return string
    }
}

fileprivate func out(_ string: String) {
    print(string)
}

func state(_ statement: Statement) {
    switch statement {
    case .line(let content, let color):
        out(resolveColoredString(content, color: color))
    }
}
