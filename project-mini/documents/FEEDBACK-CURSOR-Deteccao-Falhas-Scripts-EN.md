# Feedback for Cursor Development Team

## Problem Title
**Failure to Detect Errors and Interruptions in PowerShell Scripts and Build Processes**

## Date
2025-01-XX

## Context
During the development of a Rust project (fork of Zed Editor), we are using PowerShell scripts to execute `cargo build` and `cargo check` commands in an automated way. The AI agent (Claude Sonnet) is having difficulties detecting when:

1. PowerShell scripts fail silently
2. Build processes are interrupted by the user
3. Commands return error exit codes
4. Scripts execute but do not produce visible output in the terminal

## Specific Problems Found

### 1. PowerShell Scripts Execute But Don't Show Output
**Scenario:**
- PowerShell script (`run.ps1`) is executed via `run_terminal_cmd`
- The script executes `cargo build` commands that can take 10-20 minutes
- The agent does not receive visual feedback of progress
- If the script fails, the agent does not detect it immediately

**Example:**
```powershell
# Command executed
"C:\Program Files\PowerShell\7\pwsh.exe" -File "project-mini\scripts\run.ps1" -Phase 0

# Result: Exit code 0, but no visible output
# The agent assumes success, but the script may have actually failed
```

### 2. Interrupted Build Processes Are Not Detected
**Scenario:**
- `cargo build --release` is started (can take 20+ minutes)
- User interrupts the process (Ctrl+C)
- The agent continues waiting indefinitely
- There is no timeout mechanism or interruption detection

**Impact:**
- Significant time loss
- Agent gets "stuck" waiting for a process that has already ended
- User needs to manually cancel the agent's operation

### 3. Exit Codes Are Not Adequately Checked
**Scenario:**
- PowerShell script executes a command that fails
- Script returns exit code 1
- `run_terminal_cmd` returns exit code, but the agent does not consistently check it
- Agent assumes success based on absence of exception

### 4. Output from Scripts with `Clear-Host` Is Not Captured
**Scenario:**
- PowerShell scripts use `Clear-Host` at the beginning
- Subsequent output is not captured by `run_terminal_cmd`
- Agent does not see progress messages or errors

## Proposed Solutions

### 1. Real-Time Output Streaming
**Recommendation:**
- Add support for streaming output from long-running processes
- Allow the agent to see incremental output (e.g., "Compiling crate X...")
- Implement callback or event to notify progress

**Desired API example:**
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

### 2. Process Interruption Detection
**Recommendation:**
- Periodically check if the process is still running
- Detect interruption signals (SIGINT, SIGTERM)
- Return specific status when process is interrupted

**Example:**
```typescript
{
  exitCode: null,
  interrupted: true,
  duration: 120000, // 2 minutes before being interrupted
  output: "Compiling... [interrupted]"
}
```

### 3. Configurable Timeout
**Recommendation:**
- Allow configurable timeout per command
- Return specific error when timeout is reached
- Allow agent to cancel long operations

**Example:**
```typescript
run_terminal_cmd({
  command: "cargo build --release",
  timeout: 1800000, // 30 minutes
  onTimeout: () => {
    // Callback when timeout is reached
  }
})
```

### 4. Mandatory Exit Code Verification
**Recommendation:**
- Always check exit code after execution
- Throw exception or return error when exit code != 0
- Clearly document that exit code 0 does not guarantee success

### 5. Capture Output Even with Clear-Host
**Recommendation:**
- Capture all process output, including before Clear-Host
- Or disable Clear-Host when executed via run_terminal_cmd
- Provide flag to control screen clearing behavior

## Impact on Development

### Current Problems
1. **Productivity Loss:**
   - Agent gets "stuck" waiting for processes that have already failed
   - User needs to manually intervene constantly
   - Rework necessary when agent does not detect failures

2. **Lack of Confidence:**
   - We cannot trust that the agent will detect errors
   - We need to manually verify all results
   - Additional verification scripts are necessary

3. **User Experience:**
   - Frustration seeing agent "frozen"
   - Need to cancel and restart operations
   - Loss of context when operations are interrupted

## Real Case Example

**Situation:**
Executing PowerShell script that runs `cargo build --release`:

```powershell
# Script: project-mini/scripts/run.ps1
# Executes: cargo build --release --package mini
# Expected time: 15-20 minutes
```

**What happens:**
1. Agent executes script via `run_terminal_cmd`
2. Script starts `cargo build`
3. User sees there is an error (via manual monitoring)
4. User interrupts process (Ctrl+C)
5. Agent continues waiting for `run_terminal_cmd` response
6. After 8 hours, user realizes agent is "stuck"
7. User needs to manually cancel agent operation

**What should happen:**
1. Agent executes script
2. Agent receives output in real time
3. Agent detects error or interruption immediately
4. Agent reports problem and stops execution
5. Agent suggests next action

## Priority
**HIGH** - This problem significantly impacts productivity and reliability of the agent in projects involving long builds.

## Technical Information

### Environment
- **Operating System:** Windows 10/11
- **Shell:** PowerShell Core 7 (`C:\Program Files\PowerShell\7\pwsh.exe`)
- **Build Tool:** Cargo (Rust)
- **Typical build time:** 15-30 minutes for large projects

### Affected Commands
- `cargo build --release`
- `cargo check --workspace`
- PowerShell scripts that execute long processes
- Any command that can take more than 5 minutes

## Implementation Suggestions

### Option 1: Status Polling
```typescript
// Check process status every X seconds
setInterval(() => {
  if (processHasTerminated(pid)) {
    handleTermination();
  }
}, 5000);
```

### Option 2: Process Events
```typescript
// Use native operating system events
process.on('exit', (code) => {
  handleExit(code);
});

process.on('SIGINT', () => {
  handleInterruption();
});
```

### Option 3: Wrapper with Timeout
```typescript
// Wrapper that adds automatic timeout
function runWithTimeout(cmd, timeout) {
  return Promise.race([
    run_terminal_cmd(cmd),
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Timeout')), timeout)
    )
  ]);
}
```

## Conclusion

The ability to detect failures and interruptions in long-running processes is critical for the effectiveness of the AI agent in real development projects. Implementing the suggested improvements would significantly increase the agent's reliability and productivity.

## Contact
If you need more information or additional examples, I am available to provide.

---

**Note:** This feedback was generated during the development of the "mini editor" project (fork of Zed Editor) using Cursor IDE with Claude Sonnet 4.5 agent.
