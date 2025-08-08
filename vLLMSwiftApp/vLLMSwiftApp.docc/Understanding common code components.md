# Understanding common code components

Learn about the common code components of the application

## Overview

Reusing code in an application significantly enhances development efficiency, maintainability, and scalability. Additionally, code reuse promotes consistency across the app, ensuring uniform behavior and easier debugging. This application demonstrates extensive code reuse through shared components that are utilized across all five chat implementations.

## Shared user interface components

### Chat input interface

All chat implementations share a common text input interface for collecting user prompts. The ``ChatInputView`` is a reusable view component that provides a consistent user experience across all chat implementations.

``ChatInputView`` performs the following major functions:
- **Multiline text collection**: Uses a TextEditor with flexible height to accommodate various prompt lengths
- **Send button management**: Provides a paperplane icon button that becomes disabled during inference requests
- **Visual feedback**: Shows a ProgressView spinner while requests are being processed
- **Closure-based interaction**: Accepts an `onSend` closure parameter that allows each chat implementation to handle prompt submission according to its specific networking approach
- **Input validation**: Prevents submission of empty or whitespace-only messages
- **State management**: Accepts an `isSending` parameter to coordinate UI state with parent views

All five chat implementations (``LlamaStackChatView``, ``FoundationChatView``, ``AlamoFireChatView``, ``SwiftOpenAIChatView``, and ``MacPawOpenAIChatView``) utilize this shared component, ensuring consistent user interaction patterns.

### Chat message representation

The ``ChatMessage`` class provides a unified model for representing individual chat messages across all implementations.

Key features of ``ChatMessage``:
- **Observable architecture**: Uses the `@Observable` macro for real-time UI updates during streaming responses
- **Unique identification**: Each message has a UUID for proper SwiftUI list management and scrolling
- **Role-based messaging**: Supports user, system, and assistant message types through the `ChatMessageRole` enum
- **Timestamp tracking**: Includes automatic timestamp assignment for message ordering and potential persistence
- **Reactive content updates**: The content property updates in real-time as streaming responses are received

This shared model ensures that all chat implementations display messages consistently and support real-time updates during streaming inference responses.

### Chat bubble rendering

While not extracted into a separate reusable component, all chat implementations use a consistent "ChatBubble" pattern for message display:
- **Visual distinction**: User messages appear on the right with blue background and white text
- **Assistant messages**: Appear on the left with gray background and primary text color
- **Consistent styling**: All implementations use the same rounded rectangle styling, padding, and layout patterns
- **Accessibility**: Proper frame alignment and spacing for optimal readability

## Server management components

### Server configuration model

The ``Server`` class provides the foundational data model for all vLLM server configurations, supporting both Llama-Stack and OpenAI-compatible endpoints.

``Server`` includes the following properties:
- **Unique naming**: Server names are marked with `@Attribute(.unique)` for Swift Data uniqueness constraints
- **Flexible URL configuration**: Supports various endpoint configurations including custom ports and paths
- **Optional authentication**: API key field supports servers with and without authentication requirements
- **API type specification**: `APIEndpointType` enum distinguishes between Llama-Stack and OpenAI-compatible servers
- **Model specification**: Optional model name field for specifying inference models

### Server list management

The ``ServerListView`` provides comprehensive server management functionality used by all chat implementations.

Key features include:
- **Swift Data integration**: Automatic persistence and retrieval of server configurations
- **Visual indicators**: Lock icons indicate authentication status, API type badges show endpoint types
- **Selection management**: Supports single server selection for editing and deletion operations
- **Contextual actions**: Toolbar buttons for adding and removing servers with confirmation dialogs
- **Swipe gestures**: Support for swipe-to-delete functionality with confirmation dialogs
- **TipKit integration**: Displays ``CreateServerTip`` to guide new users through initial server setup

### Server editing interface

The ``ServerEditView`` provides a reusable form-based interface for creating and modifying server configurations.

Component features:
- **Dual-mode operation**: Supports both new server creation and existing server modification
- **Comprehensive form fields**: Text fields for name, URL, API key, and model name configuration
- **API type selection**: Picker interface for choosing between Llama-Stack and OpenAI-compatible endpoints
- **Validation logic**: Input validation with save button state management
- **Closure-based callbacks**: Uses onSave and onCancel closures for flexible integration with parent views
- **Draft state management**: Maintains temporary state during editing to prevent accidental data loss

## User guidance system

### Contextual tips

The application includes a comprehensive TipKit integration for user onboarding:

- **Application configuration**: ``ApplicationTipConfiguration`` centralizes tip settings and display frequency
- **Server creation guidance**: ``CreateServerTip`` appears when no servers are configured, guiding users to create their first server
- **Navigation guidance**: ``ChooseMenuItemTip`` helps users navigate to chat functionality after server setup
- **State-aware display**: Tips appear and dismiss based on application state and user progress

## Architectural patterns

### MVVM consistency

All chat implementations follow a consistent MVVM (Model-View-ViewModel) architecture:
- **Observable ViewModels**: Each chat view is paired with an `@Observable` ViewModel that handles API integration
- **Separation of concerns**: Views handle UI presentation while ViewModels manage data and networking logic
- **Consistent patterns**: All ViewModels implement similar `setServer()` and `sendMessage()` methods
- **Error handling**: Each ViewModel provides appropriate error handling for its networking approach

### Real-time updates

All implementations use consistent patterns for real-time streaming updates:
- **Observable properties**: ViewModels expose `llmResponse` properties that update during streaming
- **UI synchronization**: Views use `onChange()` modifiers to update chat message content in real-time
- **Thread safety**: Appropriate use of `MainActor` dispatching where required for UI updates

### Common error handling patterns

While each implementation handles errors specific to its networking library, all follow similar patterns:
- **Custom error enums**: Each ViewModel defines specific error types for its approach
- **User-friendly messages**: Errors are translated into readable messages displayed in the chat interface
- **Graceful degradation**: Failed requests don't crash the application but provide informative feedback


