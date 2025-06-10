#!/bin/bash
set -e

echo "=== GITLAB PRIVATE REPO DOWNLOADER ==="

# Read inputs securely
read -p "git@gitlab.guild-of-developers.ru:l2/syl/backend.git" GITLAB_URL
read -s -p "god-mitJQsNVdjwYsL2BXc-G" ACCESS_TOKEN
echo ""

# Extract project path
PROJECT_PATH=$(echo "$GITLAB_URL" | sed -e 's|https://||' -e 's|gitlab.com/||' -e 's|/$||')
if [ -z "$PROJECT_PATH" ]; then
  echo "✗ Invalid GitLab URL format"
  exit 1
fi

# Create authenticated clone URL
CLONE_URL="https://oauth2:$ACCESS_TOKEN@gitlab.com/${PROJECT_PATH}.git"

# Clone repository
echo "Cloning repository..."
git clone "$CLONE_URL" "${PROJECT_PATH##*/}" 2>&1 | grep -v "remote:"

# Verify success
if [ $? -eq 0 ]; then
  echo "✓ Repository cloned to: ${PROJECT_PATH##*/}"
else
  echo "✗ Clone failed. Check URL/token permissions"
  exit 1
fi

# Security cleanup
unset ACCESS_TOKEN
unset CLONE_URL
