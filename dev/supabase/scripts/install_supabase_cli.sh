#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
  if command -v brew >/dev/null 2>&1; then
    echo "Installing supabase via brew"
    brew install supabase/tap/supabase
  else
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh/"
    exit 1
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Installing supabase via install script"
  curl -sL https://supabase.com/cli/install | sh
else
  echo "Please install supabase CLI manually for your OS. See https://supabase.com/docs/guides/cli"
  exit 1
fi

echo "Supabase CLI installed. Run 'supabase --version' to verify."
