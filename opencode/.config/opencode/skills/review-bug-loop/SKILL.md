---
name: review-bug-loop
description: Iteratively review your work for bugs, fixing them in a loop (max 5 passes)
disable-model-invocation: true
---

# Iterative Bug Review Loop

Review all work done in this conversation for bugs and issues. Run this as an iterative loop with a maximum of **5 passes**.

## Process

For each pass (starting at pass 1):

1. **Spawn a subagent** (using the Task tool with `subagent_type: "general-purpose"`) with this prompt:

   > Review all code changes made in this conversation. Look for:
   > - Logic errors and off-by-one mistakes
   > - Missing error handling at system boundaries
   > - Incorrect variable references or typos in code
   > - Broken imports or missing dependencies
   > - Race conditions or ordering issues
   > - Security vulnerabilities (injection, XSS, etc.)
   > - Syntax errors or invalid configuration
   > - Regressions — changes that break existing functionality
   >
   > For each bug found: describe the issue, which file and line it's in, and fix it directly.
   >
   > At the very end of your response, output exactly one of these lines:
   > - `BUGS_FOUND: <number>` — how many bugs you found and fixed
   > - `BUGS_FOUND: 0` — if no bugs were found

2. **Parse the result.** Extract the `BUGS_FOUND` count from the subagent's response.

3. **Decide next step:**
   - If `BUGS_FOUND: 0` — stop the loop and report success.
   - If bugs were found AND this was pass 5 — stop the loop and report that the max was reached.
   - If bugs were found AND passes remain — report what was fixed, then start the next pass.

## Reporting

After the loop ends, give a summary:
- Total number of passes run
- Total bugs found and fixed across all passes
- Whether it exited clean (0 bugs) or hit the max (5 passes)
