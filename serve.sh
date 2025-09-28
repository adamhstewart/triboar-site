#!/bin/bash

# Kill any existing containers first
docker-compose down 2>/dev/null || true
docker rm tailwind-watcher 2>/dev/null || true

# Build the Hugo image if it doesn't exist
docker-compose build

# Start Tailwind watcher in background with output
docker-compose run -d --name tailwind-watcher hugo sh -c "export NPM_CONFIG_CACHE=/tmp/.npm && cd /tmp && npm install tailwindcss@3.4.0 && cd /src && npx tailwindcss -i ./assets/css/style.css -o ./static/css/output.css --config ./tailwind.config.js --watch"

# Function to show both logs
show_logs() {
  echo "=== Starting Hugo server and Tailwind watcher ==="
  echo "Hugo server will be available at http://localhost:1313"
  echo "Press Ctrl+C to stop"
  echo ""

  # Show both logs in parallel
  (
    echo "🎨 Tailwind CSS:"
    docker logs -f tailwind-watcher 2>&1 | sed 's/^/[Tailwind] /'
  ) &

  (
    echo "🚀 Hugo:"
    docker-compose up hugo 2>&1 | sed 's/^/[Hugo] /'
  ) &

  # Wait for both processes
  wait
}

# Trap Ctrl+C to clean up
trap 'docker stop tailwind-watcher; docker rm tailwind-watcher; docker-compose down; exit' INT

# Show logs
show_logs