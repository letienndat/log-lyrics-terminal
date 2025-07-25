import Foundation

extension String {
    func splitBySpacesPreserveAll() -> [Self] {
        var result: [Self] = []
        var buffer = ""

        for char in self {
            if char == " " {
                if !buffer.isEmpty {
                    result.append(buffer)
                    buffer = ""
                }
                result.append(" ")
            } else {
                buffer.append(char)
            }
        }

        if !buffer.isEmpty {
            result.append(buffer)
        }

        return result
    }
}

func usleep(_ second: Double) {
    let microseconds = UInt32(second * 1_000_000)
    usleep(microseconds)
}

let timeDelay: Double = 0.1
let timeDelayChar: Double = 0.05
let colorMap: [String: String] = [
    "{reset}": "\u{001B}[0;0m",
    "{red}": "\u{001B}[0;31m",
    "{green}": "\u{001B}[0;32m",
    "{yellow}": "\u{001B}[0;33m",
    "{blue}": "\u{001B}[0;34m",
    "{purple}": "\u{001B}[0;35m",
    "{cyan}": "\u{001B}[0;36m",
    "{light}": "\u{001B}[0;37m",
    "{bold}": "\u{001B}[1m"
]

let fileInput = "lyrics.txt"
let fileURL = URL(fileURLWithPath: "./\(fileInput)")

do {
    var value = try String(contentsOf: fileURL, encoding: .utf8)

    colorMap.forEach { tag, ansi in
        value = value.replacingOccurrences(of: tag, with: ansi)
    }

    value.components(separatedBy: .newlines).forEach { line in
        let splited = line.splitBySpacesPreserveAll()
        splited.forEach { key in
            if key == " " {
                print(key, terminator: "")
                fflush(stdout)
                usleep(timeDelay)
            } else {
                key.forEach { char in
                    print(char, terminator: "")
                    fflush(stdout)
                    usleep(timeDelayChar)
                }
            }
        }
        print()
    }
}
catch {
    print("Count't read file with path \(fileURL.absoluteString)")
}