#!/bin/bash

echo "🚀 Starting master script: run-all.sh"

# Loop through all .sh files except push.sh and run them
for script in *.sh; do
  if [[ "$script" != "push.sh" && -f "$script" ]]; then
    echo "🔧 Running $script..."

    # Make sure it's executable
    chmod +x "$script"

    # Run the script and capture exit code
    ./"$script"
    status=$?

    if [ $status -ne 0 ]; then
      echo "❌ Error in $script (exit code $status). Attempting recovery..."

      # Basic recovery logic
      if grep -q "Permission denied" "$script"; then
        echo "🔐 Fixing permission..."
        chmod +x "$script"
      elif grep -q "command not found" "$script"; then
        echo "📦 Missing command. Please install required tools."
      else
        echo "⚠️ Unknown error. Skipping $script."
      fi
    else
      echo "✅ $script ran successfully."
    fi

    echo "----------------------------------------"
  fi
done

echo "🎯 All scripts processed."
