#!/bin/bash

TODAY=$(date -u)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "`git status -s`" ]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

if [[ "$BRANCH" != "main" ]]; then
  read -p "You are not on the main branch. Normally you would deploy from main. Are you sure that you want to proceed? (Y/n) " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]
  then
    echo "Aborting the deploy."
    exit 1;
  fi
fi

echo "Pulling last changes from origin"
git fetch origin main
git pull origin main

# Initialize gh-pages branch if it doesn't exist
if ! git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
  echo "Creating gh-pages branch for first time"
  git checkout --orphan gh-pages
  git rm -rf .
  echo "# GitHub Pages" > README.md
  git add README.md
  git commit -m "Initial gh-pages commit"
  git push origin gh-pages
  git checkout main
fi

echo "Fetching gh-pages branch"
git fetch origin gh-pages

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Building Tailwind CSS for production"
docker-compose run --rm hugo sh -c "export NPM_CONFIG_CACHE=/tmp/.npm && cd /tmp && npm install tailwindcss@3.4.0 && cd /src && /tmp/node_modules/.bin/tailwindcss -i ./assets/css/style.css -o ./static/css/output.css --config ./tailwind.config.js --minify"

echo "Generating Hugo site"
docker-compose run --rm hugo hugo --minify --environment production

echo "Adding .nojekyll file to prevent Jekyll processing"
cp .nojekyll public/

echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "Deploy to gh-pages: $TODAY"

echo "Deploying to GitHub Pages"
git push origin gh-pages:gh-pages

echo "Cleaning up"
cd ..
git worktree remove public

echo "✅ Deployment complete! Your site will be available at:"
echo "https://$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')/"