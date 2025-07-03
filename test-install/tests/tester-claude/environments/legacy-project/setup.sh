#!/bin/bash
# setup.sh - Create a legacy Node.js project for adoption testing
set -euo pipefail

echo "Creating legacy project test environment..."

# Get the script directory before changing directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create a temporary directory for initial state
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Create the project structure
cd "$TEMP_DIR"
mkdir -p legacy-todo-app/src

# Create package.json
cat > legacy-todo-app/package.json << 'EOF'
{
  "name": "legacy-todo-app",
  "version": "1.0.0",
  "description": "A legacy todo application that needs claudepm",
  "main": "index.js",
  "scripts": {
    "test": "jest",
    "build": "webpack --mode production",
    "dev": "webpack-dev-server --mode development",
    "lint": "eslint src/",
    "start": "node index.js"
  },
  "author": "Test Author",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.0",
    "react": "^18.0.0"
  }
}
EOF

# Create README with TODOs
cat > legacy-todo-app/README.md << 'EOF'
# Legacy Todo App

This is an existing project that we want to adopt into claudepm.

## Setup
1. Run `npm install`
2. Run `npm run dev` for development
3. Run `npm test` to run tests

## TODO
- Add user authentication 
- Implement data persistence
- Add API documentation
- Fix the search functionality bug
- Migrate from webpack to vite

## Notes
IMPORTANT: The database connection string must be set in environment variables
NOTE: Rate limiting is implemented on all API endpoints (10 req/min)
TODO: Add proper error handling for network failures

## Architecture
The app uses Express for the backend and React for the frontend.
We're currently using local storage but need to move to a real database.
EOF

# Create source files with inline TODOs
cat > legacy-todo-app/src/index.js << 'EOF'
// Legacy todo app entry point
const express = require('express');
const app = express();

// TODO: Add proper error handling middleware
// FIXME: Security headers are missing
// NOTE: This server binds to all interfaces - security risk?

app.use(express.json());

app.get('/', (req, res) => {
    // TODO: Implement proper homepage with React
    res.send('Hello World - Todo App v1.0');
});

// NOTE: This is a temporary implementation
app.get('/api/todos', (req, res) => {
    // TODO: Connect to real database instead of mock data
    // FIXME: Add pagination for large todo lists
    res.json([
        { id: 1, text: 'Sample todo', done: false },
        { id: 2, text: 'Another todo', done: true }
    ]);
});

// TODO: Implement POST /api/todos
// TODO: Implement PUT /api/todos/:id
// TODO: Implement DELETE /api/todos/:id

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    // IMPORTANT: In production, use PM2 or similar process manager
});
EOF

# Create a test file
cat > legacy-todo-app/src/index.test.js << 'EOF'
// TODO: Write actual tests
describe('Todo API', () => {
    test('should return todos', () => {
        // FIXME: Implement this test
        expect(true).toBe(true);
    });
});
EOF

# Create .gitignore
cat > legacy-todo-app/.gitignore << 'EOF'
node_modules/
dist/
.env
*.log
EOF

# Create the archive
tar -czf initial.tar.gz -C . legacy-todo-app

# Move to final location
mv initial.tar.gz "$SCRIPT_DIR/"

echo "Initial state created successfully!"
echo "Archive contains: Legacy Node.js project with TODOs ready for adoption"