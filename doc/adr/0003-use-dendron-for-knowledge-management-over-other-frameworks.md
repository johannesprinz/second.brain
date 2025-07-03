# 3. Use Dendron for knowledge management over other frameworks

Date: 2025-07-03

## Status

Accepted

## Context

We need a knowledge management system that supports software engineering teams
in:

- Organizing hierarchical technical documentation
- Linking related concepts and decisions
- Supporting both individual and team knowledge sharing
- Integrating with existing development workflows
- Scaling with growing documentation needs
- Supporting both structured documentation and free-form notes

The main alternatives considered were:

- **Dendron** - Hierarchical note-taking with VS Code integration
- **Obsidian** - Graph-based knowledge management
- **Notion** - All-in-one workspace with databases
- **GitBook** - Documentation-focused platform
- **TiddlyWiki** - Non-linear documentation system
- **Roam Research** - Bi-directional linking notes
- **Plain file system** - Simple directory structure with markdown files

## Decision

We will use **Dendron** as our primary knowledge management framework.

## Consequences

### Positive

- **Hierarchical organization**: Natural fit for technical documentation with
  clear structure (e.g., `project.backend.api.authentication`)
- **VS Code integration**: Seamless integration with our primary development
  environment
- **Schema support**: Structured templates for consistent documentation (ADRs,
  runbooks, etc.)
- **Lookup and navigation**: Fast search and navigation with fuzzy matching
- **Linking and references**: Automatic backlinks and reference tracking
- **Publishing capabilities**: Can generate static sites from documentation
- **Markdown-native**: Works with our existing markdown toolchain
- **Developer-friendly**: Git-based workflow that developers understand
- **Extensible**: Rich plugin ecosystem and customization options

### Negative

- **Learning curve**: Team needs to learn Dendron conventions and commands
- **VS Code dependency**: Requires VS Code for optimal experience
- **File proliferation**: Can generate many files that need organization
- **Less visual**: Not as graphically rich as Obsidian or Roam Research
- **Smaller community**: Less widespread adoption than some alternatives

### Mitigation

- Provide team training on Dendron workflows and best practices
- Document our Dendron conventions and schemas
- Use schemas to enforce consistent structure
- Regular maintenance to prune unused or outdated notes
- Backup and export strategies to avoid vendor lock-in

## Implementation

- Set up Dendron workspace in VS Code
- Create schemas for common documentation types (ADRs, runbooks, meeting notes)
- Establish naming conventions for hierarchical organization
- Configure daily notes for team knowledge capture
- Set up publishing pipeline for external documentation sharing

## References

- [Dendron Documentation](https://www.dendron.so/)
- [Dendron vs Obsidian Comparison](https://wiki.dendron.so/notes/8pg3zx3j2r0eqs7i7wzaojk/)
- [Building a Second Brain methodology](https://www.buildingasecondbrain.com/)
- [ADR-0002: Use Markdown instead of AsciiDoc](./0002-use-markdown-instead-of-asciidoc-for-documentation.md)
