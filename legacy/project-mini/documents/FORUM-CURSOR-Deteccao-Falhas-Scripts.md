# AI Agent Cannot Detect Errors and Interruptions in PowerShell Scripts

**Category:** Bug Reports

---

## Where does the bug appear (feature/product)?

**Cursor IDE** - AI Agent Terminal / `run_terminal_cmd` tool

---

## Describe the Bug

The AI agent (Claude Sonnet) cannot reliably detect when:

1. **PowerShell scripts fail** - Scripts return error exit codes, but the agent doesn't detect them or cannot read error logs
2. **Build processes are interrupted** - When a user interrupts a long-running process (Ctrl+C), the agent continues waiting indefinitely
3. **Commands fail silently** - Scripts execute but produce no visible output, and the agent assumes success
4. **Exit codes are ignored** - The `run_terminal_cmd` tool returns exit codes, but the agent doesn't consistently check them

This affects:
- Integrated terminal execution
- Agent terminal execution
- Long-running build processes (Rust `cargo build`, etc.)
- PowerShell scripts that execute multiple commands sequentially

---

## Steps to Reproduce

### Scenario 1: Error Detection Failure

1. Create a PowerShell script (`test-error.ps1`) that executes a failing command:
   ```powershell
   # test-error.ps1
   $ErrorActionPreference = "Stop"
   cargo check --package nonexistent_package_xyz
   if ($LASTEXITCODE -ne 0) {
       Write-Host "Error detected: Exit code $LASTEXITCODE"
       exit $LASTEXITCODE
   }
   ```

2. Ask the AI agent to execute the script:
   ```
   Execute: "C:\Program Files\PowerShell\7\pwsh.exe" -File "test-error.ps1"
   ```

3. **Observe:** The script will fail with exit code 1 (package doesn't exist)

4. **Expected Behavior:**
   - Agent receives exit code 1
   - Agent reads the error message from cargo output
   - Agent reports the error and suggests a fix

5. **Actual Behavior:**
   - Agent may not detect the error exit code
   - Agent cannot read the error log/output
   - Agent assumes success or gets stuck waiting
   - User must manually check the terminal to see the error

### Scenario 2: Interruption Not Detected

1. Start a long-running build process via agent:
   ```
   Execute: cargo build --release --package large_crate
   # This can take 20+ minutes
   ```

2. Wait for the build to start (you'll see "Compiling..." messages in terminal)

3. Manually interrupt the process by pressing `Ctrl+C` in the terminal

4. **Expected Behavior:**
   - Agent detects that the process was interrupted
   - Agent stops waiting for the command to complete
   - Agent reports that the process was interrupted
   - Agent can continue with next steps

5. **Actual Behavior:**
   - Agent continues waiting indefinitely
   - Agent doesn't detect the interruption
   - Agent appears "frozen" or "stuck"
   - User must manually cancel the agent's operation
   - Agent may wait for hours before user notices

### Scenario 3: Output Not Captured / Silent Failures

1. Create a PowerShell script (`test-silent.ps1`) that fails silently:
   ```powershell
   # test-silent.ps1
   Clear-Host
   Write-Host "Starting build process..."
   cargo check --package nonexistent_package 2>&1 | Out-Null
   if ($LASTEXITCODE -ne 0) {
       Write-Host "Build failed with exit code: $LASTEXITCODE"
       exit $LASTEXITCODE
   }
   Write-Host "Build completed successfully"
   ```

2. Execute the script via agent:
   ```
   Execute: "C:\Program Files\PowerShell\7\pwsh.exe" -File "test-silent.ps1"
   ```

3. **Expected Behavior:**
   - Agent sees "Starting build process..." message
   - Agent sees "Build failed with exit code: 1" message
   - Agent detects the failure and reports it

4. **Actual Behavior:**
   - Agent doesn't see any output (especially after `Clear-Host`)
   - Agent doesn't detect the failure
   - Agent assumes success because no error was visible
   - Script may have failed, but agent continues as if it succeeded

### Scenario 4: Error Log Not Readable

1. Create a PowerShell script that writes errors to a log file:
   ```powershell
   # test-log.ps1
   cargo test --package my_crate 2>&1 | Tee-Object -FilePath "error.log"
   if ($LASTEXITCODE -ne 0) {
       Write-Host "Tests failed. Check error.log for details."
       exit $LASTEXITCODE
   }
   ```

2. Execute the script via agent

3. Script fails and creates `error.log` with error details

4. **Expected Behavior:**
   - Agent detects exit code != 0
   - Agent reads the `error.log` file to understand the error
   - Agent reports the specific error and suggests fixes

5. **Actual Behavior:**
   - Agent detects exit code != 0 (sometimes)
   - Agent cannot read or doesn't read the `error.log` file
   - Agent reports generic "command failed" without details
   - User must manually read the log and send it to agent

---

## Expected Behavior

### 1. Real-Time Output Streaming

The agent should receive output chunks as they are produced, allowing it to:
- See progress messages (e.g., "Compiling crate X...", "Checking Y...")
- Detect errors as they occur, not just at the end
- Provide feedback to the user about what's happening
- Make decisions based on intermediate output

**Example:**
```
Agent executes: cargo build --release
Agent receives (in real-time):
  → "Compiling mini v0.1.0"
  → "Compiling mini_ui v0.1.0"
  → "error[E0277]: trait bound not satisfied"
  → Agent immediately detects error and stops waiting
  → Agent reads full error message and suggests fix
```

### 2. Interruption Detection

When a user interrupts a process (Ctrl+C), the agent should:
- Detect the interruption signal immediately
- Stop waiting for the process to complete
- Report that the process was interrupted
- Continue with the next logical step (or ask user what to do)

**Example:**
```
User presses Ctrl+C after 2 minutes of build
Agent detects: Process interrupted after 120 seconds
Agent reports: "Build was interrupted by user. Should I retry or continue?"
Agent does NOT wait indefinitely
```

### 3. Exit Code Verification

The agent should:
- Always check exit codes after command execution
- Treat any non-zero exit code as an error
- Not assume success based on absence of exceptions
- Have clear error handling for different exit codes

**Example:**
```
Script returns: exit code 1
Agent checks: if (exitCode !== 0) { handleError() }
Agent reports: "Command failed with exit code 1"
Agent reads: error output/log to understand why
```

### 4. Error Log Reading

When scripts generate error logs, the agent should:
- Automatically read log files mentioned in error messages
- Parse log files to extract specific error information
- Use error details to suggest fixes
- Not require user to manually read and send logs

**Example:**
```
Script output: "Error detected. Check log: D:\proj\logs\error.log"
Agent automatically: Reads D:\proj\logs\error.log
Agent extracts: "error[E0277]: trait bound `T: Display` not satisfied"
Agent suggests: "Add `Display` trait bound to type `T`"
```

### 5. Timeout Mechanism

Long-running processes should:
- Have configurable timeouts (default: reasonable for command type)
- Return specific error when timeout is reached
- Allow agent to cancel operations that are taking too long
- Provide progress updates so agent knows process is still running

**Example:**
```
Agent executes: cargo build --release (timeout: 30 minutes)
After 25 minutes: Agent receives progress update "Still compiling..."
After 30 minutes: Agent receives timeout error
Agent reports: "Build timed out after 30 minutes. Process may still be running."
Agent suggests: "Check terminal or increase timeout if build is still active"
```

### 6. Output Capture (Including Clear-Host)

The agent should:
- Capture all process output, including before `Clear-Host`
- See all messages written by scripts
- Not lose output due to screen clearing commands
- Have access to both stdout and stderr streams

**Example:**
```
Script executes:
  Clear-Host
  Write-Host "Starting..."
  cargo build

Agent sees:
  → "Starting..." (even after Clear-Host)
  → All cargo build output
  → Error messages if any
```

### 7. Process Status Monitoring

For long-running processes, the agent should:
- Periodically verify the process is still running
- Detect if process has terminated unexpectedly
- Handle zombie processes or hung processes
- Provide status updates to user

**Example:**
```
Agent starts: cargo build --release
Every 5 minutes: Agent checks if process is still running
If process terminated: Agent detects immediately and reports
If process hung: Agent can detect and suggest killing it
```

---

## Operating System

**Windows 10/11**
- Build: 10.0.26220
- Shell: PowerShell Core 7 (`C:\Program Files\PowerShell\7\pwsh.exe`)

---

## Current Cursor Version

**Version:** [Please fill: Menu → About Cursor → Copy]

---

## For AI issues: which model did you use?

**Claude 3.5 Sonnet** (via Cursor IDE)

---

## For AI issues: add Request ID with privacy disabled

[If available, add Request ID from failed operations]

---

## Related Issues and Community Reports

This issue has been **widely reported** by the Cursor community. Research shows:

- **8+ open GitHub issues** (since 2024)
- **10+ active forum discussions**
- **5+ Reddit threads**
- **6-12 months without official resolution**

**Main related issues:**
- [GitHub #3215](https://github.com/cursor/cursor/issues/3215): "Terminal Commands Never Auto-Complete"
- [GitHub #3501](https://github.com/cursor/cursor/issues/3501): "Terminal Commands Get Stuck/Interrupted"
- [Forum #118302](https://forum.cursor.com/t/cursor-must-not-decide-when-to-time-out-and-stop-terminal-commands-on-its-own/118302): "Cursor Must Not Timeout Arbitrarily"
- [Forum #48389](https://forum.cursor.com/t/how-can-i-prevent-cursor-from-making-the-same-mistakes-when-executing-powershell/48389): "PowerShell Exit Code Not Captured"

**Community workaround:** The most effective workaround used by the community is to **print error logs directly to the terminal** (which we have implemented in our scripts), as the Cursor agent can see terminal output but cannot automatically read log files.

**Full research document:** See `project-mini/reports/The-Cursor-Error-Detection-Problem.md` for complete analysis.

---

## Additional Information

### Real-World Impact

**Project Context:**
- Developing a Rust project (fork of Zed Editor)
- Using PowerShell scripts to automate `cargo build`, `cargo check`, `cargo test`
- Build times: 15-30 minutes for release builds
- Scripts detect errors correctly, but agent cannot read error logs

**Example from our project:**

```powershell
# Script: project-mini/scripts/run-fase-2.ps1
# Executes: cargo test --package mini_ui

# Script output (correctly detects error):
[2/3] Executando 'FASE 2: Testes Unitários (cargo test)'...
✗ O comando retornou um erro, verifique o log em: D:\proj\mini\project-mini\logs\fase2-cargo-test.log
[Tipo de erro: exit-code]

# Agent behavior:
# - Script correctly detects error ✅
# - Script correctly cancels next command ✅
# - BUT agent cannot read the log to identify specific error ❌
# - User must manually execute script and send log to agent ❌
```

**Productivity Impact:**
- Each compilation error requires manual intervention
- Time lost: ~5-10 minutes per error
- Project phases taking 2x longer than estimated
- Agent gets "stuck" waiting for interrupted processes

### Technical Details

**Affected Commands:**
- `cargo build --release` (15-30 minutes)
- `cargo check --workspace` (2-5 minutes)
- `cargo test --workspace` (3-10 minutes)
- Any PowerShell script executing long processes

**Script Structure:**
Our scripts use:
- Exit code checking
- Error keyword detection in logs
- Cascading cancellation (stop subsequent commands if one fails)
- Individual log files per command

The scripts work correctly - the problem is that the agent cannot:
1. Read the error logs that scripts generate
2. Detect when processes are interrupted
3. See real-time output from long-running processes

### Proposed Solutions

1. **Real-time output streaming:**
   ```typescript
   run_terminal_cmd({
     command: "cargo build --release",
     streamOutput: true,
     onOutput: (chunk: string) => {
       // Agent receives output chunks in real time
     },
     timeout: 3600000 // 1 hour
   })
   ```

2. **Process interruption detection:**
   - Periodically check if process is still running
   - Detect interruption signals (SIGINT, SIGTERM)
   - Return specific status when interrupted

3. **Configurable timeout:**
   - Allow timeout per command
   - Return specific error when timeout reached
   - Allow agent to cancel long operations

4. **Mandatory exit code verification:**
   - Always check exit code after execution
   - Throw exception or return error when exit code != 0
   - Clearly document that exit code 0 doesn't guarantee success

5. **Capture output even with Clear-Host:**
   - Capture all process output, including before Clear-Host
   - Or disable Clear-Host when executed via run_terminal_cmd
   - Provide flag to control screen clearing behavior

### Workaround (Current)

We are currently using a workaround:
- User executes scripts manually
- User reads error logs and sends them to agent
- Agent fixes errors based on provided logs

**Limitations:**
- Requires constant manual intervention
- Not scalable
- Significantly impacts productivity

---

## Does this stop you from using Cursor?

**Sometimes** - I can sometimes use Cursor, but this significantly impacts productivity and requires constant manual intervention for build/compilation tasks.

---

## Priority

**HIGH** - This problem significantly impacts productivity and reliability of the AI agent in projects involving long builds and compilation processes.

---

**Note:** This issue was identified during development of the "mini editor" project (fork of Zed Editor) using Cursor IDE with Claude Sonnet agent on Windows 10/11.
