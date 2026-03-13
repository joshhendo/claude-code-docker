# Claude Code Global Instructions

## Serena MCP Server

A Serena MCP server is available, providing language server protocol (LSP) capabilities for precise, symbol-aware code navigation and analysis. Prefer Serena's tools over text search when you need accurate semantic information.

### When to use Serena

- **Finding definitions**: Use `serena_find_symbol` or `serena_go_to_definition` instead of grep when looking up where a function, class, or variable is defined.
- **Finding usages**: Use `serena_find_references` to locate all call sites or references to a symbol across the codebase.
- **Understanding structure**: Use `serena_get_symbols_overview` to get a high-level view of the symbols in a file or module before editing it.
- **Renaming symbols**: Use `serena_rename_symbol` to safely rename a symbol and all its references in one step.
- **Checking diagnostics**: Use `serena_get_diagnostics` to surface compiler errors or type errors before and after making changes.

### General guidance

- Invoke Serena tools early when exploring unfamiliar code — a symbol overview costs little and prevents incorrect assumptions.
- Prefer `serena_find_references` over `grep` for symbol usages; LSP results are scope-aware and won't produce false positives from comments or string literals.
- After making edits, run `serena_get_diagnostics` to catch type errors or broken references before declaring a task complete.
- Serena operates on the project at `/project`. No additional configuration is needed.
