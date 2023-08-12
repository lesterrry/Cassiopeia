//
//  Statements.swift
//  Cassiopeia
//
//  Created by aydar.media on 12.08.2023.
//

import Rainbow

enum Statement {
    case line(String, Color? = nil)
    case space(Int8 = 1)
}

fileprivate func resolveColoredString(_ string: String, color: Color? = nil) -> String {
    if let c = color {
        return string.applyingCodes(c)
    } else {
        return string
    }
}

fileprivate func out(_ string: String...) {
    if string.count == 0 {
        print()
    } else {
        print(string[0])
    }
}

func state(_ statement: Statement) {
    switch statement {
    case .line(let content, let color):
        out(resolveColoredString(content, color: color))
    case .space(let times):
        for _ in 1...times { out() }
    }
}
