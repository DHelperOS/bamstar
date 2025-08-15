#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $(basename "$0") <template-name> [target-dir]"
  exit 2
fi
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/$1"
TARGET_DIR="${2:-$(pwd)}"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Template not found: $TEMPLATE_DIR"
  exit 1
fi

echo "Applying template: $TEMPLATE_DIR -> $TARGET_DIR"
cp -a "$TEMPLATE_DIR/." "$TARGET_DIR/"

# Replace placeholder project name in pubspec.yaml and README if present
if [ -f "$TARGET_DIR/pubspec.yaml" ]; then
  sed -i.bak "s/^name: .*$/name: example_app/" "$TARGET_DIR/pubspec.yaml" && rm -f "$TARGET_DIR/pubspec.yaml.bak"
fi
if [ -f "$TARGET_DIR/README.md" ]; then
  sed -i.bak "s/# canwa/# example_app/" "$TARGET_DIR/README.md" && rm -f "$TARGET_DIR/README.md.bak"
fi

echo "Template applied. Run 'flutter pub get' in the target directory if needed." 
