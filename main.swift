import Foundation

// MARK: - Config
let fileURL = URL(fileURLWithPath: "./lyrics.txt")

let colorMap: [String: String] = [
    "{reset}": "\u{001B}[0m",
    "{bold}": "\u{001B}[1m",

    "{red}": "\u{001B}[0;31m",
    "{brightRed}": "\u{001B}[1;31m",

    "{green}": "\u{001B}[0;32m",
    "{brightGreen}": "\u{001B}[1;32m",

    "{yellow}": "\u{001B}[0;33m",
    "{brightYellow}": "\u{001B}[1;33m",

    "{blue}": "\u{001B}[0;34m",
    "{brightBlue}": "\u{001B}[1;34m",

    "{purple}": "\u{001B}[0;35m",
    "{brightPurple}": "\u{001B}[1;35m",

    "{cyan}": "\u{001B}[0;36m",
    "{brightCyan}": "\u{001B}[1;36m",

    "{light}": "\u{001B}[0;37m",
    "{white}": "\u{001B}[1;37m",
    "{orange}": "\u{001B}[38;5;208m",
    "{pink}": "\u{001B}[38;5;205m",
    "{teal}": "\u{001B}[38;5;37m",
    "{gray}": "\u{001B}[38;5;244m",
    "{silver}": "\u{001B}[38;5;250m",
    "{gold}": "\u{001B}[38;5;220m",
    "{lime}": "\u{001B}[38;5;154m",
    "{sky}": "\u{001B}[38;5;117m",
    "{magenta}": "\u{001B}[38;5;129m"
]

// ANSI 256-color color codes for faded tints of basic colors
let fadeShadesMap: [String: [Int]] = [
    colorMap["{red}"]!:          [52, 88, 89, 124, 125, 160, 161, 196, 197, 203],
    colorMap["{brightRed}"]!:    [160, 196, 197, 203, 210, 9],
    
    colorMap["{green}"]!:        [22, 28, 34, 40, 46, 82, 118, 154, 190, 156],
    colorMap["{brightGreen}"]!:  [82, 118, 154, 156, 190, 10],
    
    colorMap["{yellow}"]!:       [100, 142, 148, 184, 190, 226, 227, 229],
    colorMap["{brightYellow}"]!: [184, 190, 226, 227, 229, 11],
    
    colorMap["{blue}"]!:         [17, 18, 19, 20, 21, 27, 33, 39, 45, 51],
    colorMap["{brightBlue}"]!:   [27, 33, 39, 45, 51, 12],
    
    colorMap["{purple}"]!:       [53, 89, 90, 125, 126, 161, 162, 198, 199],
    colorMap["{brightPurple}"]!: [129, 135, 141, 171, 177, 13],
    
    colorMap["{cyan}"]!:         [44, 45, 51, 87, 123, 159, 195],
    colorMap["{brightCyan}"]!:   [123, 159, 195, 14],
    
    colorMap["{light}"]!:        [250, 251, 252, 253, 254, 255],
    colorMap["{white}"]!:        [254, 255, 15],
    
    colorMap["{orange}"]!:       [130, 166, 172, 208, 214, 216, 220],
    colorMap["{pink}"]!:         [169, 170, 198, 199, 200, 205, 13],
    colorMap["{teal}"]!:         [30, 37, 38, 43, 44, 50, 51],
    colorMap["{gray}"]!:         [238, 239, 240, 241, 244, 245, 246],
    colorMap["{silver}"]!:       [247, 248, 249, 250, 251],
    colorMap["{gold}"]!:         [136, 178, 179, 184, 220, 221],
    colorMap["{lime}"]!:         [118, 154, 156, 190, 154],
    colorMap["{sky}"]!:          [45, 51, 75, 117, 123, 159],
    colorMap["{magenta}"]!:      [129, 135, 141, 171, 177],
    
    "":                          Array(232...255) // fallback: grayscale
]

func usleep_s(_ second: Double) {
    let microseconds = UInt32(second * 1_000_000)
    usleep(microseconds)
}

func ansiColor(code: Int) -> String {
    return "\u{001B}[38;5;\(code)m"
}

func fadePrint(text: String, color: String, duration: Double, column: Int = 0) {
    let shades = fadeShadesMap[color] ?? fadeShadesMap[""]!
    let stepTime = duration / Double(shades.count)

    for shade in shades {
        print("\u{001B}[\(column + 1)G", terminator: "")
        let ansi = ansiColor(code: shade)
        print("\(ansi)\(text)\u{001B}[0m", terminator: "")
        fflush(stdout)
        usleep_s(stepTime)
    }
}

func printReady() {
    [3, 2, 1].forEach { second in
        print("\r\(second)", terminator: "")
        fflush(stdout)
        usleep_s(1)
    }
}

// MARK: - Main

print("\u{001B}[2J") // Auto clear terminal
print("\u{001B}[H") // Reset location cursor
print("\u{001B}[?25l", terminator: "") // Hide cursor

do {
    let raw = try String(contentsOf: fileURL, encoding: .utf8)
    let lines = raw.components(separatedBy: .newlines)
    
    let tagPattern = #"(\{[^}]+\})|([^\{]+)"#
    let regex = try NSRegularExpression(pattern: tagPattern, options: [])
    
    var currentColor = ""
    var currentFadeDuration: Double = 0
    var currentDelayDuration: Double = 0
    
    for line in lines {
        var column = 0
        let nsLine = line as NSString
        let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
        
        for match in matches {
            let token = nsLine.substring(with: match.range)
            
            if token.starts(with: "{") && token.hasSuffix("}") {
                if let ansi = colorMap[token] {
                    currentColor = ansi
                    print(ansi, terminator: "")
                } else if token.starts(with: "{f-") {
                    let value = token.dropFirst(3).dropLast()
                    currentFadeDuration = Double(value) ?? 1
                } else if token.starts(with: "{d-") {
                    let value = token.dropFirst(3).dropLast()
                    currentDelayDuration = Double(value) ?? 1
                }
                continue
            }
            
            if currentDelayDuration > 0 {
                usleep_s(currentDelayDuration)
            }
            
            if currentFadeDuration > 0 {
                fadePrint(
                    text: token,
                    color: currentColor,
                    duration: currentFadeDuration,
                    column: column
                )
            } else {
                print("\(column == 0 ? "" : " ")\(currentColor)\(token)", terminator: "")
                fflush(stdout)
            }
            
            column += token.count + 1
        }
        print()
    }
    
    print("\u{001B}[?25h", terminator: "") // Show cursor again
    usleep_s(10)
} catch {
    print("Could not read file at path: \(fileURL.path)")
}