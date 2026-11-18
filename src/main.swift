import Foundation

// shae-swift-macos-system-monitor
// -------------------------------
// macOS system monitor written in Swift, built on the SHAE Field Manual
// design system.
//
// Features:
//   - show CPU, memory, disk usage
//   - show uptime, hostname
//   - show battery status (if available)
//   - formatted console output
//
// Requires: swiftc / macOS (not available locally). Cannot compile-test locally.
//
// Build: swiftc -O src/main.swift -o monitor
// Run:   ./monitor [--interval N]
//
// Design system (SHAE Field Manual): console output uses the paper
// #F2EEE5, ink #191712, oxide #B3341B palette via ANSI escapes; tables
// are hairline-ruled, left-aligned, monospace metadata; no gradients,
// glass, pills, shadows.

let ANSI_RESET = "\u{1B}[0m"
let ANSI_BOLD  = "\u{1B}[1m"
let ANSI_INK   = "\u{1B}[38;2;25;23;18m"    // #191712
let ANSI_OXIDE = "\u{1B}[38;2;179;52;27m"   // #B3341B
let ANSI_PAPER = "\u{1B}[38;2;242;238;229m" // #F2EEE5

/// Run a command and return its trimmed standard output.
func shell(_ executable: String, _ args: String...) -> String {
    var allArgs = [executable] + args
    let process = Process()
    process.executableURL = URL(fileURLWithPath: allArgs.removeFirst())
    process.arguments = allArgs
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = nil
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

/// First non-empty line matching `prefix`, with the prefix stripped.
func valueFor(prefix: String, in output: String) -> String {
    for line in output.split(separator: "\n", omittingEmptySubsequences: true) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix(prefix) {
            return String(trimmed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        }
    }
    return ""
}

func parseDouble(_ s: String) -> Double {
    Double(s.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")) ?? 0
}

func parseInt(_ s: String) -> Int {
    Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
}

// MARK: - Hostname / OS

func hostname() -> String {
    ProcessInfo.processInfo.hostName
}

func osVersion() -> String {
    let v = ProcessInfo.processInfo.operatingSystemVersion
    return "macOS \(v.major).\(v.minor).\(v.patch)"
}

// MARK: - CPU

func cpuUsage() -> Double {
    // Sample twice, one second apart, and compute util from `top`.
    _ = shell("/usr/bin/top", "-l", "2", "-s", "0")
    let output = shell("/usr/bin/top", "-l", "2", "-s", "0")
    let lines = output.split(separator: "\n", omittingEmptySubsequences: true)
    // Use the last "CPU usage" line (second sample).
    var usageLine = ""
    for line in lines.reversed() {
        if line.contains("CPU usage") {
            usageLine = String(line)
            break
        }
    }
    if usageLine.isEmpty { return 0 }
    // "CPU usage: 5.3% user, 2.1% sys, 92.6% idle"
    let idlePart = usageLine.components(separatedBy: "idle").first ?? ""
    let idle = parseDouble(idlePart.components(separatedBy: ":").last ?? "0")
    return max(0, min(100, 100 - idle))
}

// MARK: - Memory

func memoryUsage() -> (total: Int64, used: Int64, percent: Double) {
    let memsize = shell("/usr/sbin/sysctl", "-n", "hw.memsize")
    let total = Int64(parseInt(memsize))
    let pagesize = Int64(parseInt(shell("/usr/sbin/sysctl", "-n", "hw.pagesize")))
    let vmstat = shell("/usr/bin/vm_stat")
    var freePages: Int64 = 0
    for line in vmstat.split(separator: "\n") {
        let t = line.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("Pages free:") {
            freePages = Int64(parseInt(t.components(separatedBy: ":").last ?? "0").replacingOccurrences(of: ".", with: ""))
        }
    }
    let available = freePages * pagesize
    let used = max(0, total - available)
    let percent = total > 0 ? Double(used) / Double(total) * 100 : 0
    return (total, used, percent)
}

func formatBytes(_ bytes: Int64) -> String {
    var value = Double(bytes)
    let units = ["B", "KB", "MB", "GB", "TB"]
    var i = 0
    while value >= 1024 && i < units.count - 1 {
        value /= 1024
        i += 1
    }
    return String(format: "%.2f %@", value, units[i])
}

// MARK: - Disk

func diskUsage() -> (total: Int64, used: Int64, percent: Double) {
    let output = shell("/bin/df", "-k", "/")
    var total: Int64 = 0, used: Int64 = 0
    for line in output.split(separator: "\n") {
        let parts = line.split(separator: " ", omittingEmptySubsequences: true)
        if parts.count >= 4 && parts[0] != "Filesystem" {
            total = Int64(parseInt(String(parts[1]))) * 1024
            used = Int64(parseInt(String(parts[2]))) * 1024
            break
        }
    }
    let percent = total > 0 ? Double(used) / Double(total) * 100 : 0
    return (total, used, percent)
}

// MARK: - Uptime

func uptime() -> String {
    let output = shell("/usr/bin/uptime")
    // "  14:32 up 2 days,  3:12, ..."
    if let up = output.components(separatedBy: " up ").last {
        return String(up.split(separator: ",").first ?? up).trimmingCharacters(in: .whitespaces)
    }
    return "unknown"
}

// MARK: - Battery

func batteryStatus() -> String {
    let output = shell("/usr/bin/pmset", "-g", "batt")
    if output.contains("No Battery Notices Available") || !output.contains("%") {
        return "N/A (no battery)"
    }
    // Extract percentage and source.
    var pct = "unknown"
    if let range = output.range(of: #"\d+%"#, options: .regularExpression) {
        pct = String(output[range])
    }
    var source = "AC"
    if output.contains("AC Power") { source = "AC Power" }
    else if output.contains("Battery Power") { source = "Battery Power" }
    return "\(pct) · \(source)"
}

// MARK: - Rendering

func printSection(_ title: String, _ body: String) {
    print("\(ANSI_BOLD)\(ANSI_INK)\(title)\(ANSI_RESET)")
    print("\(ANSI_PAPER)----------------------------------------\(ANSI_RESET)")
    print(body)
    print()
}

func printHeader() {
    print("\(ANSI_BOLD)\(ANSI_INK)shae-swift-macos-system-monitor\(ANSI_RESET)")
    print("\(ANSI_PAPER)----------------------------------------\(ANSI_RESET)")
    print("  \(ANSI_INK)Host:\(ANSI_RESET) \(hostname())")
    print("  \(ANSI_INK)OS:\(ANSI_RESET) \(osVersion())")
    print()
}

func main() {
    let args = CommandLine.arguments
    var interval: Double = 0
    for i in 0..<args.count {
        if args[i] == "--interval", i + 1 < args.count {
            interval = parseDouble(args[i + 1])
        }
    }

    repeat {
        print("\u{1B}[2J\u{1B}[H") // clear screen
        printHeader()

        let cpu = cpuUsage()
        printSection("CPU", "  Usage: \(String(format: "%.1f", cpu))%")

        let mem = memoryUsage()
        printSection("Memory", "  Total: \(formatBytes(mem.total))\n  Used: \(formatBytes(mem.used))\n  Usage: \(String(format: "%.1f", mem.percent))%")

        let disk = diskUsage()
        printSection("Disk", "  Total: \(formatBytes(disk.total))\n  Used: \(formatBytes(disk.used))\n  Usage: \(String(format: "%.1f", disk.percent))%")

        printSection("Uptime", "  \(uptime())")
        printSection("Battery", "  \(batteryStatus())")
        print("\(ANSI_OXIDE)Refresh every \(Int(interval))s (Ctrl-C to quit)\(ANSI_RESET)\n")

        if interval > 0 {
            Thread.sleep(forTimeInterval: interval)
        } else {
            break
        }
    } while true
}

main()
