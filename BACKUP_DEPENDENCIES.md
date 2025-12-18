# Backup System Dependencies

## Required Dependencies

Add these dependencies to your project:

```bash
# Install backup system dependencies
npm install googleapis pg @types/pg

# Or with yarn
yarn add googleapis pg @types/pg
```

## Dependencies Explanation

### `googleapis`
- **Purpose**: Google Sheets API client
- **Version**: Latest stable
- **Usage**: Authenticate and write data to Google Sheets

### `pg`
- **Purpose**: PostgreSQL client for Node.js
- **Version**: Latest stable  
- **Usage**: Connect to Neon PostgreSQL database

### `@types/pg`
- **Purpose**: TypeScript definitions for pg
- **Version**: Latest stable
- **Usage**: Type safety for PostgreSQL operations

## Updated package.json Dependencies Section

Add these to your existing dependencies:

```json
{
  "dependencies": {
    // ... existing dependencies
    "googleapis": "^131.0.0",
    "pg": "^8.11.3"
  },
  "devDependencies": {
    // ... existing devDependencies  
    "@types/pg": "^8.10.9"
  }
}
```

## Installation Command

Run this command in your project root:

```bash
npm install googleapis@^131.0.0 pg@^8.11.3 @types/pg@^8.10.9
```

## Verification

After installation, verify the dependencies are installed:

```bash
npm list googleapis pg @types/pg
```

You should see output similar to:
```
├── googleapis@131.0.0
├── pg@8.11.3
└── @types/pg@8.10.9
```