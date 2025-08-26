Context7 MCP Server for VS Code
================================

This VS Code extension integrates the Context7 MCP (Model Context Protocol) server to provide AI assistants with real-time access to current documentation for thousands of libraries and frameworks.

Features
--------
- Real-time Documentation Access: Provides AI models with access to current documentation for thousands of libraries and frameworks
- Automatic Library Resolution: Automatically finds and retrieves relevant documentation based on user queries
- Up-to-date Content: Always provides the latest documentation from official sources
- Easy Integration: Simple setup with no additional configuration required
- Seamless VS Code Integration: Works directly with VS Code's built-in AI features

Installation
------------
1. Clone this repository
2. Run npm install to install dependencies
3. Run npm run compile to build the extension
4. Press F5 in VS Code to launch the extension in a new Extension Development Host window

Usage
-----
The Context7 MCP server is automatically registered when the extension activates. It provides the following capabilities:

Available Functions
-------------------
- mcp_context7-new_resolve-library-id - Resolves a package/product name to a Context7-compatible library ID
- mcp_context7-new_get-library-docs - Fetches up-to-date documentation for a library

Example Usage
-------------
When using an AI assistant in VS Code, you can now ask questions like:

- "Show me how to use React hooks use context7"
- "What are the best practices for Next.js routing? use context7"
- "How do I implement authentication with Supabase? use context7"
- "Give me examples of using TypeScript decorators use context7"
- "How do I set up a GraphQL server with Apollo? use context7"
- "What are the latest features in Node.js 20? use context7"

The Context7 MCP server will automatically:

- Resolve the library name to the appropriate Context7 library ID
- Fetch the latest documentation
- Provide relevant code examples and documentation

Direct Library Access
---------------------
You can also directly specify library IDs in your prompts using the slash syntax:

"Implement basic authentication with Supabase. Use the API and documentation f"
