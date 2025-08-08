# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS/iOS SwiftUI application that demonstrates connecting to vLLM servers using different HTTP REST API approaches:
- OpenAI-compatible API 
- Llama-Stack API

The app serves as sample code for integrating various Swift HTTP client libraries with vLLM inference endpoints.

## Build and Development Commands

### Build Commands
- **Build**: Use Xcode **Product → Build** or ⌘+B
- **Clean**: Use Xcode **Product → Clean Build Folder** or ⌘+Shift+K
- **Run**: Use Xcode **Product → Run** or ⌘+R

### Testing
- **Run Tests**: Use Xcode **Product → Test** or ⌘+U
- **Test files**: Located in `vLLMSwiftAppTests/` directory

### Documentation
- **Build Documentation**: Use Xcode **Product → Build Documentation**
- **View Documentation**: Use Xcode **Help → Developer Documentation**

### Requirements
- Xcode 16.3 or later
- macOS 15.0 (Sequoia) or later
- Enable OpenAPIGenerator extension when prompted (required for SDK generation)

## Architecture

### Core Structure
- **Entry Point**: ``vLLMSwiftApp`` - App entry point with SwiftData and TipKit setup
- **Main Navigation**: ``MainAppView`` - Primary NavigationSplitView with dynamic sidebar menu
- **Data Model**: ``Server`` - SwiftData model for vLLM server configurations
- **Chat Model**: ``ChatMessage`` - Observable chat message representation

### Key Design Patterns
- **SwiftData**: Used for persistent server configuration storage
- **MVVM**: ViewModels handle API integration logic, Views handle UI
- **Observable**: Chat messages use @Observable for real-time streaming updates
- **Dynamic Navigation**: Menu items enabled/disabled based on implemented views and server availability

### API Integration Examples
The app demonstrates 5 different HTTP client approaches:
1. ``LlamaStackChatViewModel`` - Official Llama-Stack Swift client
2. ``SwiftOpenAIChatViewModel`` - SwiftOpenAI library 
3. ``MacPawOpenAIChatViewModel`` - MacPaw/OpenAI library
4. ``AlamoFireChatViewModel`` - Alamofire HTTP client
5. ``FoundationChatViewModel`` - Native URLSession

### Dependencies
- Alamofire (5.10.2)
- LlamaStackClient (0.2.2) 
- MacPaw/OpenAI (main branch)
- SwiftOpenAI (4.1.1)
- Various Swift OpenAPI packages

### Navigation Architecture
- ``MainAppView`` contains a NavigationSplitView with sidebar and detail area
- Navigation items defined in `NavSection` and `NavItem` structs
- Dynamic destination routing via `DynamicNavigationDestination` enum
- Menu items automatically disabled if no corresponding view exists

### Tips Integration
- Uses TipKit for user onboarding guidance
- ``ApplicationTipConfiguration`` centralizes tip settings
- Tips displayed contextually (e.g., when no servers configured)

### Project Structure
```
vLLMSwiftApp/
├── Models/           # Data models and ViewModels
├── Views/           # SwiftUI views 
├── Tips/            # TipKit guidance
├── Protocols/       # (Currently empty)
├── Assets.xcassets/ # App icons and colors
└── vLLMSwiftApp.docc/ # Documentation catalog
```

## Development Notes

### Server Configuration
- Servers stored via SwiftData with unique names
- Support for OpenAI and Llama-Stack API types  
- Optional API key and model name fields

### Chat Implementation Pattern
Each chat implementation follows similar structure:
- ViewModel handles API client setup and message processing
- View provides UI with ``ChatInputView`` for message input
- Real-time streaming updates via @Observable ``ChatMessage`` objects

### Common Components
- ``ChatInputView`` - Reusable text input component for chat interfaces
- ``ServerListView`` - Server management and configuration
- ``ServerEditView`` - Server parameter editing via SwiftUI Inspector

### Testing
- Unit tests focus on ViewModel functionality
- UI tests cover basic navigation flows
- Test files mirror main source structure

## Apple Documentation Standards

When creating or modifying documentation:
- Use DocC markup for all code documentation
- Follow Apple's documentation comment style with `///`
- Use proper DocC syntax for cross-references with `` `` 
- Include `@param` and `@returns` for method documentation
- Add `>Note:`, `>Warning:`, and `>Tip:` callouts appropriately
- Structure articles with proper headings and overview sections
- Include code examples in documentation where helpful
