# My Work Brain

## Getting started

1. **Launch development container**
   - If updating existing container: `Ctrl+Shift+P` → `Dev Containers: Rebuild Container`
   - If first time: `Ctrl+Shift+P` → `Dev Containers: Reopen in Container`

2. **Install dependencies**

   ```bash
   npm ci --include-dev
   ```

3. **Initialize environment** (optional, only if using LDAP features)

   ```bash
   npm run setup
   ```

4. **Test CLI tools are working**

   ```bash
   # Test Marp CLI
   npx marp --version
   # Test Mermaid CLI  
   npx mmdc --version
   # Test Dendron CLI
   npx dendron --version
   ```

5. **Edit away** - Start creating your knowledge base!

6. **Pre-commit cleanup**

   ```bash
   # Fix formatting issues and highlight spelling issues
   npm run pre-commit
   ```

### Document Conversion Examples

```bash
# Convert markdown to docx/pdf using Pandoc + Mermaid
npm run convert-from-md -- ./notes/your-note.md
npm run convert-from-md -- ./notes/your-note.md pdf

# Convert to presentations using Marp
npm run marp-html -- ./notes/your-presentation.md
npm run marp-pdf -- ./notes/your-presentation.md  
npm run marp-pptx -- ./notes/your-presentation.md

# Build Dendron static site
npm run dendron-build
```

All conversion tools are also available as VS Code tasks:
`Ctrl+Shift+P` → `Tasks: Run Task` → Choose your conversion method

1. **Commit your changes**

## Writing notes

Use [Dendron][dendron] inside [VS Code][vscode] either within a [GitHub code
space][codespace] or [dev container][devcontainer].

## Convert notes

### Pandoc Conversion

Use the _Convert from Markdown_ task in [tasks.json](.vscode/tasks.json).

1. Open the note you wish to convert.
1. `CTRL+SHIFT+P`/`CMD+SHIFT+P` => `Run Task` => `Convert from Markdown` =>
   `enter` => Select the format (docx | pdf) => `enter`.

This will:

1. convert all mermaid diagrams into images
1. replace the mermaid code blocks with links to the generated images
1. use PanDoc to create the document
1. dump all output into the [bin](./bin) folder

From there you can also copy all the generated images or use the installed
PanDoc extension to convert the \*.temp.md document to other formats supported
by PanDoc.

### Marp Presentation Conversion

Use the _Convert with Marp_ task for creating presentations from Markdown.

1. Open the markdown file you wish to convert to a presentation.
1. `CTRL+SHIFT+P`/`CMD+SHIFT+P` => `Run Task` => `Convert with Marp` =>
   `enter` => Select the format (html | pdf | pptx) => `enter`.

This will create presentation slides from your markdown file using Marp syntax.
Output files are saved to the [bin](./bin) folder.

**Marp CLI Commands:**

```bash
# Convert to HTML presentation
npm run marp-html -- your-file.md
# Convert to PDF presentation  
npm run marp-pdf -- your-file.md
# Convert to PowerPoint presentation
npm run marp-pptx -- your-file.md
```

### Dendron CLI Operations

Use Dendron CLI for advanced operations beyond the VS Code extension.

**Build static site:**

```bash
npm run dendron-build
```

**Export notes:**

```bash
npm run dendron-export
```

**VS Code Task:**

1. `CTRL+SHIFT+P`/`CMD+SHIFT+P` => `Run Task` => `Build Dendron Site`

All CLI tools (Marp, Mermaid, Dendron) are installed as npm dev dependencies for consistent versioning and reproducibility.

## Megalinter

Rather than trying out all these different a specific linter per file type or
language, can I get away with just using
[Megalinter](https://github.com/oxsecurity/megalinter)?

```bash
# To setup the secret use
# read -p 'Domain username: ' username
# read -sp 'Password: ' password
# echo $username | docker secret create lychee_username -
# echo $password | docker secret create lychee_password -
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v $(pwd):/tmp/lint:rw \
  -v $(pwd)/lychee_username:/run/secrets/lychee_username \
  -v $(pwd)/lychee_password:/run/secrets/lychee_password \
  oxsecurity/megalinter:v8
```

## Dependencies

- Tools
  - [Visual Studio Code][vscode]
  - [Dendron][dendron]
- Developer Environment
  - [Container](Dockerfile)
  - [Extensions](.devcontainer/devcontainer.json)
- Packages
  - [Node.js](package.json)

## Todo

- [ ] Run all the audits and output to file.sarif
- [ ] Set 'npm run pre-commit` as a git commit hook?
- Link checking

  - [ ] Remote links

    ```bash
    docker run --rm \
     -v /var/run/docker.sock:/var/run/docker.sock:rw \
     -v $(pwd):/tmp/lint:rw \
     -v $(pwd)/lychee_username:/run/secrets/lychee_username \
     -v $(pwd)/lychee_password:/run/secrets/lychee_password \
     -e ENABLE_LINTERS=MARKDOWN_MARKDOWN_LINK_CHECK oxsecurity/megalinter:v8
    ```

  - [ ] Dendron links
    - Use the cli `dendron doctor` command

- [ ] Mermaid diagram support to latest version
- [ ] Augment notes with existing information
  - System information from Services Catalogue
- [ ] Install credential cache and setup script to initialise it

  ```bash
  sudo apt-get install libsecret-tools
  # Check if LDAP password is retrieved
  if [ -z "$ldap_password" ]; then
    echo "LDAP password not found in keyring. Please store it using 'secret-tool store --label=\"LDAP Password\" ldap user'."
    exit 1
  fi
  ```

- [ ] Full security screen using trivy
  - `sudo trivy fs /` or we can scan from SBOM and output to X format
  - `docker sbom second.brain:2025.11.1.0.0-f620a57 --format spdx-json --output git/second.brain/bin/sbom.json`

## Periodic Tasks

### Update person metadata from LDAP

```bash
# the script will repeatedly ask for the password
# You can cache it using
export ldap_password="my super secret password"
export ldap_user="corp\."
# Update person metadata from LDAP
./scripts/ldap_update.sh
# Sometimes the data does not match as the first name last name combo from the
# title don't match the display name as the, so you can check on display name
# to fix the title and re-run.
# List all display name results
./ldap_lookup.sh John*
# or
./ldap_lookup.sh John*Smith
# List only the first matched result for first name and last name
./ldap_lookup.sh Jonathan Smith
```

### Update container dependencies

```bash
# List available updates
sudo apt update && sudo apt list --upgradable
# Update all
sudo apt upgrade --assume-yes
sudo apt clean
# List all updated items and update the ./Dockerfile
```

## Versioning

Combining the strengths of Semantic Versioning (SemVer) and Calendar Versioning
(CalVer) can provide a comprehensive versioning scheme that conveys both
compatibility and release date information. Here’s a hybrid approach you might
find useful:

### Hybrid Versioning Scheme

Format: `YYYY.MM.MAJOR.MINOR.PATCH`

- **YYYY.MM:** Represents the year and month of the release, providing a clear
  indication of when the version was released.
- **MAJOR:** Indicates incompatible API changes.
- **MINOR:** Indicates backward-compatible new features.
- **PATCH:** Indicates backward-compatible bug fixes.

### Example

For a release in September 2024 with a major update, a minor feature addition,
and a few bug fixes, the version might look like:

```plaintext
2024.09.2.1.3
```

- `2024.09`: Released in September 2024.
- `2`: Major version, indicating significant changes.
- `1`: Minor version, indicating new features.
- `3`: Patch version, indicating bug fixes.

### Benefits

Compatibility Information: The MAJOR.MINOR.PATCH format provides clear
information about the nature of changes and compatibility. Date Information: The
YYYY.MM format makes it easy to see when the version was released, helping users
understand the recency of updates.

### Implementation

Major, Minor and Patch numbers are stored in ./VERSION file. The complete
version number can be read using the following command:

```bash
## Loads the version file
source VERSION
# String munges the version number based on the above scheme
echo $(date +'%Y.%m').$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD)
## Builds the docker file according to the above scheme
docker build -t second.brain:latest -t second.brain:$(date +'%Y.%m').$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD) .
## Clean up older images
docker images --filter "dangling=false" --format "{{.Repository}}:{{.Tag}}" | grep -v "second.brain:latest" | grep "second.brain:" | xargs -r docker rmi
## Run versioned image terminal to inspect
docker run --rm -it second.brain:$(date +'%Y.%m').$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD) /bin/bash
## Run latest image terminal to inspect
docker run --rm -it second.brain:latest /bin/bash
```

[vscode]: https://code.visualstudio.com/
[dendron]: https://www.dendron.so/
[devcontainer]: https://code.visualstudio.com/docs/devcontainers/containers
[codespace]: https://github.com/features/codespaces
