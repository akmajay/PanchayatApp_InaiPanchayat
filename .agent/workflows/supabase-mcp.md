---
description: How to interact with Supabase database using MCP
---

# Supabase MCP Workflow

This workflow documents how to use the Supabase MCP (Model Context Protocol) for database operations.

## Project Reference
- **Project ID**: `skbbbmpirxuptuuonfyh`
- **Region**: `ap-southeast-1`

## Available MCP Commands

### 1. List Projects
```
mcp_supabase-mcp-server_list_projects
```
Lists all Supabase projects connected to your account.

### 2. List Tables
```
mcp_supabase-mcp-server_list_tables
  project_id: skbbbmpirxuptuuonfyh
  schemas: ["public"]
```
Shows all tables in the specified schema.

### 3. Apply Migration (DDL Operations)
// turbo
```
mcp_supabase-mcp-server_apply_migration
  project_id: skbbbmpirxuptuuonfyh
  name: migration_name_in_snake_case
  query: <SQL DDL statements>
```
Use for CREATE TABLE, ALTER TABLE, CREATE INDEX, CREATE FUNCTION, etc.

### 4. Execute SQL (DML Operations)
// turbo
```
mcp_supabase-mcp-server_execute_sql
  project_id: skbbbmpirxuptuuonfyh
  query: <SQL query>
```
Use for SELECT, INSERT, UPDATE, DELETE queries.

### 5. List Migrations
```
mcp_supabase-mcp-server_list_migrations
  project_id: skbbbmpirxuptuuonfyh
```
Shows all applied migrations.

### 6. Generate TypeScript Types
```
mcp_supabase-mcp-server_generate_typescript_types
  project_id: skbbbmpirxuptuuonfyh
```
Generates TypeScript types from database schema.

### 7. Get Security Advisors
```
mcp_supabase-mcp-server_get_advisors
  project_id: skbbbmpirxuptuuonfyh
  type: security
```
Check for security issues like missing RLS policies.

## Best Practices

1. **Always use `apply_migration` for DDL** - This tracks schema changes properly
2. **Use `execute_sql` for queries** - For reading/writing data
3. **Run security advisors after DDL changes** - Check for missing RLS policies
4. **Generate types after schema changes** - Keep Flutter models in sync
