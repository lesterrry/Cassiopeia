//
//  ConsoleUtils.swift
//  Cassiopeia
//
//  Created by Aydar Nasibullin on 15.08.2023.
//

import Darwin.C

struct ConsoleUtils {
    public static func setEcho(on: Bool) {
        var t = termios()
        
        tcgetattr(STDIN_FILENO, &t)
        if on {
            t.c_lflag |= tcflag_t(ECHO)
        } else {
            t.c_lflag &= ~tcflag_t(ECHO)
        }
        tcsetattr(STDIN_FILENO, TCSANOW, &t)
    }
}
