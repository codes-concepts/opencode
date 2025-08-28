#!/bin/bash
set -e

# current git branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

echo "Building opencode development version..."

# Clean up any previous builds
rm -rf tui packages/opencode/dist/temp

# Build TUI component
echo "Building TUI component..."
cd packages/tui
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w -X main.Version=dev" -o ../../tui ./cmd/opencode/main.go
cd ../..

# Build main opencode binary
echo "Building main binary..."
cd packages/opencode
mkdir -p dist/temp/bin
cp ../../tui dist/temp/bin/tui
bun build --define OPENCODE_TUI_PATH="'../../../dist/temp/bin/tui'" --define OPENCODE_VERSION="'dev'" --compile --target=bun-linux-x64 --outfile=dist/temp/bin/opencode ./src/index.ts
rm dist/temp/bin/tui
cd ../..

# Copy to a convenient location
cp packages/opencode/dist/temp/bin/opencode ~/.local/bin/oc-$current_branch
chmod +x ~/.local/bin/oc-$current_branch
echo "✅ Build complete! Binary available at: ~/.local/bin/oc-$current_branch"
