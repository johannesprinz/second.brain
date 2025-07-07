# 2. Use Markdown instead of AsciiDoc for documentation

Date: 2025-07-03

## Status

Accepted

## Context

We need a markup language for our documentation system that supports:

- Wide ecosystem support and tooling
- Simple syntax for quick adoption
- Integration with modern development workflows
- Support for presentations, technical docs, and knowledge management
- Compatibility with GitHub, VS Code, and other developer tools

The main alternatives considered were:

- **Markdown** - Simple, widely adopted markup language
- **AsciiDoc** - More feature-rich but complex markup language
- **reStructuredText** - Python ecosystem standard
- **Plain text** - Too limited for rich content

## Decision

We will use **Markdown** as our primary markup language for all documentation.

## Consequences

### Positive

- **Universal support**: Markdown is supported natively by GitHub, GitLab, VS
  Code, and virtually all modern development tools
- **Low learning curve**: Simple syntax that new team members can learn quickly
- **Rich ecosystem**: Extensive tooling available including:
  - Marp for presentations
  - Dendron for knowledge management
  - Pandoc for format conversion
  - Mermaid for diagrams
- **Lightweight**: Fast to write and process
- **Version control friendly**: Plain text that diffs well in Git
- **Multi-purpose**: Works for docs, presentations, notes, and websites

### Negative

- **Limited advanced features**: Lacks some advanced formatting options of
  AsciiDoc
- **Inconsistent standards**: Different flavors (CommonMark, GitHub Flavoured
  Markdown, etc.)
- **Table limitations**: Complex tables are harder to create than in AsciiDoc

### Mitigation

- Use CommonMark standard where possible for consistency
- Leverage HTML embedding when advanced formatting is needed
- Use Mermaid for complex diagrams instead of ASCII art
- Supplement with tooling (Prettier, linters) for consistent formatting

## References

- [CommonMark Specification](https://commonmark.org/)
- [GitHub Flavoured Markdown Spec](https://github.github.com/gfm/)
- [Marp for Presentations](https://marp.app/)
- [Dendron Documentation](https://www.dendron.so/)
