# Understanding basic application structure

Learn about the basic structure of the application

## Overview

The goal of the application is to provide comprehensive examples of how to implement chat interfaces that connect to vLLM servers using different HTTP client approaches. The application demonstrates both Llama-Stack API integration and multiple OpenAI-compatible API implementations, showcasing various Swift networking libraries and patterns.

Application functionality can be broken down into three major categories:
- **Server definition and maintenance:** allows the user to create, update, and delete the server definitions that are required to make inference requests.
- **API selection and configuration:** support for both Llama-Stack and OpenAI-compatible APIs with flexible server endpoint configuration.
- **Multiple chat implementations:** demonstrate different approaches to HTTP networking, streaming responses, and real-time UI updates.

### Application startup

When the application starts it performs three basic tasks:
- Define the Swift Data schema for ``Server`` persistence and attach the container to the ``MainAppView``.
- Configure the TipKit framework using ``ApplicationTipConfiguration`` for user onboarding guidance.
- Create the base application user interface via the view defined in ``MainAppView``.

### Application data

Swift Data is used to persist data across application launches. The only persistent data implemented is the list of servers that the application can connect to. The exact data that is stored for each server can be found in ``Server``, which includes:
- Server name (unique identifier)
- Base URL for the inference endpoint
- API type (Llama-Stack or OpenAI-compatible)
- Optional API key for authentication
- Optional model name for inference requests

> Warning: Persistent data maintained for Tips is automatically managed by TipKit. The code in ``vLLMSwiftApp`` init() contains `try? Tips.resetDatastore()` that resets the tips data store so that usage info isn't persisted across app usage. You must remove this line to test tip functionality as it will behave during recurring usage of the application.

### Navigation architecture

When the application starts up, the ``MainAppView`` appears and establishes a NavigationSplitView as the base structure for the user interface. The left sidebar contains a dynamically generated menu organized into logical sections:

**Settings Section:**
- **vLLM Servers** - Server configuration and management via ``ServerListView``
- **Chat Preferences** - Placeholder for future chat customization options

**Llama-Stack Example Section:**
- **Llama-Stack Chat** - Official Llama-Stack SDK implementation via ``LlamaStackChatView``

**OpenAI Examples Section:**
- **URLSession Chat** - Native Foundation networking via ``FoundationChatView``  
- **Alamofire Chat** - Third-party HTTP library via ``AlamoFireChatView``
- **SwiftOpenAI Chat** - Community OpenAI SDK via ``SwiftOpenAIChatView``
- **MacPaw → OpenAI Chat** - Alternative OpenAI SDK via ``MacPawOpenAIChatView``

The navigation system uses a dynamic approach where menu items are enabled based on the availability of implemented views. This is controlled through the `DynamicNavigationDestination` enum and `NavItem` destination mapping.

### Server management workflow

The user must define one or more servers before any chat functionality can be used. Server management is handled through the "vLLM Servers" menu item:

1. **Server List Display:** ``ServerListView`` shows all configured servers in a SwiftData-backed list
2. **Server Creation:** Plus button opens ``ServerEditView`` in a SwiftUI Inspector sheet
3. **Server Editing:** Clicking on existing servers opens ``ServerEditView`` for modification  
4. **Server Deletion:** Selection plus minus button removes servers from persistent storage

When no servers are configured, the application automatically navigates to the server management view and displays the ``CreateServerTip`` to guide new users.

### Chat implementation approaches

The application demonstrates five distinct approaches to implementing chat interfaces with vLLM servers:

**Llama-Stack Implementation:**
- Uses the official [llama-stack-client-swift SDK](https://github.com/meta-llama/llama-stack-client-swift)
- Leverages auto-generated code from OpenAPI specifications  
- Provides type-safe API interactions with contract-first development
- Handles text, image, and tool call content types
- Review the <doc:Understanding-the-Llama-Stack-chat> article for details

**Foundation Implementation:**
- Uses Apple's native URLSession for zero-dependency networking
- Demonstrates comprehensive error handling across multiple layers
- Shows modular architecture with separate request preparation and response processing
- Review the <doc:Understanding-the-Foundation-chat> article for details

**Alamofire Implementation:**
- Uses the popular [Alamofire](https://github.com/Alamofire/Alamofire) HTTP networking library
- Demonstrates advanced streaming capabilities with server-sent events
- Shows sophisticated error handling and JSON processing
- Review the <doc:Understanding-the-Alamofire-chat> article for details

**SwiftOpenAI Implementation:**
- Uses the [SwiftOpenAI](https://github.com/jamesrochabrun/SwiftOpenAI) community library
- Demonstrates factory-based service creation patterns
- Shows flexible configuration for custom endpoints
- Review the <doc:Understanding-the-SwiftOpenAI-chat> article for details

**MacPaw OpenAI Implementation:**
- Uses the [MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) community library
- Demonstrates high-level SDK integration with streaming support
- Shows comprehensive error categorization and finish reason handling
- Review the <doc:Understanding-the-MacPaw-OpenAI-chat> article for details

### Common components and patterns

All chat implementations share several common architectural patterns:

**MVVM Architecture:** Each chat view is paired with an observable ViewModel that handles API integration and data management.

**Shared UI Components:** 
- ``ChatInputView`` - Reusable text input component for prompt collection
- ``ChatMessage`` - Observable model for real-time message updates
- Chat bubble rendering with user/assistant visual distinction

**Real-time Updates:** All implementations use the `@Observable` macro for immediate UI updates during streaming responses.

**Error Handling:** Each implementation provides comprehensive error handling appropriate to its networking approach.

### User guidance system

The application integrates TipKit for contextual user guidance:
- ``CreateServerTip`` - Guides users to create their first server configuration
- ``ChooseMenuItemTip`` - Helps users navigate to chat functionality after server setup
- ``ApplicationTipConfiguration`` - Centralizes tip configuration and display frequency

Tips are displayed contextually based on application state, ensuring users understand the required setup steps for successful operation.
