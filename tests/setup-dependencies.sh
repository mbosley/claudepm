#!/bin/bash
# Setup script for installing test dependencies

echo "claudepm Test Dependencies Setup"
echo "==============================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    
    if command -v brew >/dev/null 2>&1; then
        echo "Installing test dependencies with Homebrew..."
        echo ""
        echo "This will install:"
        echo "  - bats-core (Bash Automated Testing System)"
        echo "  - jq (JSON processor)"
        echo ""
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew install bats-core jq
        else
            echo "Installation cancelled"
            exit 1
        fi
    else
        echo "Homebrew not found. Please install from https://brew.sh"
        exit 1
    fi
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux"
    
    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing test dependencies with apt..."
        echo ""
        echo "This will install:"
        echo "  - bats (Bash Automated Testing System)"
        echo "  - jq (JSON processor)"
        echo ""
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt-get update
            sudo apt-get install -y bats jq
        else
            echo "Installation cancelled"
            exit 1
        fi
    else
        echo "apt-get not found. Please install bats and jq manually."
        exit 1
    fi
else
    echo "Unsupported OS: $OSTYPE"
    echo "Please install bats and jq manually"
    exit 1
fi

echo ""
echo "Checking Python installation..."
if command -v python3 >/dev/null 2>&1; then
    echo "✓ Python 3 found: $(python3 --version)"
else
    echo "✗ Python 3 not found. Please install Python 3 for AI behavioral tests"
fi

echo ""
echo "Setup complete! You can now run tests with:"
echo "  ./tests/framework/run-tests.sh"