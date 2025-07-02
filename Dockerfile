FROM node:20 AS base

# Install basic development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    less \
    man-db \
    sudo \
    xclip \
    # pandoc debian install suggestions at /usr/share/doc/pandoc/README.Debian
    pandoc \
    # packages required by chrome headless required by puppeteer required by mermaid-cli
    libnss3 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxkbcommon0 \
    libasound2 \
    # packages required to pandoc convert to pdf
    texlive-latex-recommended \
    lmodern \
    texlive-xetex \
    # SVG content in PDF output requires librsvg2-bin.
    librsvg2-bin \
    # For augmenting person information with LDAP information
    ldap-utils \
    # Install trivi for security scanning
    && wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    trivy \
    # Clean up app cache
    && rm -rf /var/lib/apt/lists/*

# Ensure default `node` user has access to `sudo`
ARG USERNAME=node
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Set working directory to the default workspace location
WORKDIR /workspaces/second.brain

# Switch to the default `node` user
USER $USERNAME

FROM base AS development
# Copy package.json and package-lock.json
COPY package*.json ./

# Change ownership of the copied files to the node user
RUN sudo chown -R $USERNAME:$USERNAME /workspaces/second.brain

# Install NPM packages
RUN npm ci --include-dev

FROM development AS cipipeline

# For every file type in source control
# Create a layer that copies the file to the image
# then runs all static analysis on that file type
# then run any bundling, compilation or publishing steps
# then run any tests that can be run without a running application

# might want it to exit non zero adding the following to package.json
# "ci-exit": "npm run ci-spell; ci_spell_exit=$?; npm run ci-format; ci_format_exit=$?; npm run test-markdown; test_markdown_exit=$?; exit $((ci_spell_exit + ci_format_exit + test_markdown_exit))",
RUN npm run ci

# Add a health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD less --version || exit 1