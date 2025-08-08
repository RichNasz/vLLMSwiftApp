# vLLMSwiftApp

A macOS SwiftUI application demonstrating how to build chatbot interfaces that connect to vLLM inference servers, and Llama Stack, using multiple HTTP client approaches. This sample project showcases best practices for integrating various Swift HTTP libraries that support both OpenAI-compatible and Llama-Stack APIs.

## Table of Contents
- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [API Implementations](#api-implementations)
- [Documentation](#documentation)
- [Testing](#testing)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)

## Features

- 🚀 **Multiple HTTP Client Implementations**: Compare 5 different approaches to API integration
- 🔄 **Real-time Streaming**: Live chat responses with @Observable pattern
- 💾 **Persistent Server Configuration**: SwiftData-based server management
- 🎯 **Modern SwiftUI**: Native macOS interface with NavigationSplitView
- 📚 **Complete Documentation**: DocC documentation with examples
- 🧪 **Comprehensive Testing**: Unit and UI tests for all components
- 💡 **TipKit Integration**: User guidance and onboarding

## Architecture

### API Support
vLLM accepts inference requests using these REST API endpoints:
- **OpenAI-compatible API**: Standard Chat Completions format

Llama Stack accepts inference requests using these REST API endpoints:
- **OpenAI-compatible API**: Standard Chat Completions format
- **Llama-Stack API**: Native Llama-Stack protocol

### HTTP Client Implementations
1. **LlamaStackChatViewModel** - Official Llama-Stack Swift client
2. **SwiftOpenAIChatViewModel** - SwiftOpenAI library
3. **MacPawOpenAIChatViewModel** - MacPaw/OpenAI library  
4. **AlamoFireChatViewModel** - Alamofire HTTP client
5. **FoundationChatViewModel** - Native URLSession

## Requirements

### System Requirements
- **Xcode**: Version 16.3 or later ([Mac App Store](https://apps.apple.com/us/app/xcode/id497799835) or [Apple Developer](https://developer.apple.com/xcode/))
- **macOS**: 15.0 (Sequoia) or later
- **Apple Developer Account**: Optional for device deployment

### Server Requirements
- **Llama-Stack Server**: For native Llama-Stack API testing.
  - Setup guide: [Llama-Stack Documentation](https://llama-stack.readthedocs.io/en/latest/getting_started/detailed_tutorial.html#step-1-installation-and-setup)
  - vLLM integration: [vLLM with Llama-Stack](https://blog.vllm.ai/2025/01/27/intro-to-llama-stack-with-vllm.html)
  
- **OpenAI-Compatible Server**: For Chat Completions API testing
  - **vLLM**: Open source inference server ([Documentation](https://docs.vllm.ai/en/latest/))
  - **Llama Stack**: Offers OpenAI-compatible Chat Completions endpoint. [Llama-Stack Documentation](https://llama-stack.readthedocs.io/en/latest/getting_started/detailed_tutorial.html#step-1-installation-and-setup)
  - **Local Options**: [LM Studio](https://lmstudio.ai/), [AnythingLLM](https://anythingllm.com/), [Ollama](https://ollama.com/download/mac)
  - **Cloud Options**: Use an OpenAI-compatible Chat Completions endpoint of your choice.

## Installation

### Clone the Repository

#### Option 1: Command Line
```bash
git clone https://github.com/RichNasz/vLLMSwiftApp.git
cd vLLMSwiftApp
```

Open the project in Xcode:
- Navigate to the cloned folder in Finder and double-click `vLLMSwiftApp.xcodeproj`
- Or in Xcode: **File → Open** and select the project file

#### Option 2: Xcode Integration
1. In Xcode: **Integrate → Clone...**
2. Enter repository URL: `https://github.com/RichNasz/vLLMSwiftApp.git`
3. Select the `main` branch and click **Clone**
4. Choose destination directory and click **Clone**

### Setup and Build

#### Initial Setup
1. **Enable OpenAPIGenerator Extension**
   - When prompted during first build, select "Trust & Enable"
   - Required for SDK code generation

2. **Configure Developer Account**
   - **Xcode → Settings → Accounts**
   - Add your Apple Developer account (free account sufficient)

#### Build Process
1. **Clean Build Folder**: **Product → Clean Build Folder** (⌘+Shift+K)
2. **Build Project**: **Product → Build** (⌘+B)
3. **Run Application**: **Product → Run** (⌘+R)

## Usage

### Server Configuration
1. Launch the application
2. Navigate to **Server List** in the sidebar
3. Click **+** to add a new server
4. Configure server details:
   - **Name**: Unique identifier
   - **Base URL**: Your vLLM server endpoint
   - **API Type**: OpenAI or Llama-Stack
   - **API Key**: Optional authentication
   - **Model**: Model identifier

### Chat Interface
1. Select a chat implementation from the sidebar
2. Choose your configured server
3. Start chatting with real-time streaming responses

## API Implementations

### 1. Llama-Stack Client
- **File**: `LlamaStackChatViewModel.swift`
- **Library**: Official Llama-Stack Swift client
- **Best For**: Native Llama-Stack protocol integration

### 2. SwiftOpenAI
- **File**: `SwiftOpenAIChatViewModel.swift`  
- **Library**: SwiftOpenAI (4.1.1)
- **Best For**: Comprehensive OpenAI API support

### 3. MacPaw OpenAI
- **File**: `MacPawOpenAIChatViewModel.swift`
- **Library**: MacPaw/OpenAI (main branch)
- **Best For**: Lightweight OpenAI integration

### 4. Alamofire
- **File**: `AlamoFireChatViewModel.swift`
- **Library**: Alamofire (5.10.2)
- **Best For**: Custom HTTP client implementations

### 5. Foundation URLSession
- **File**: `FoundationChatViewModel.swift`
- **Library**: Native URLSession
- **Best For**: No external dependencies

## Documentation

### Build Documentation
**Product → Build Documentation** in Xcode

### View Documentation  
**Help → Developer Documentation** in Xcode

The project includes comprehensive DocC documentation covering:
- Architecture overview
- API integration patterns
- Code examples and best practices

## Testing

### Run Tests
**Product → Test** (⌘+U) in Xcode

### Test Structure
- **Unit Tests**: ViewModel functionality and API integration
- **UI Tests**: Navigation and interface interactions
- **Test Files**: Located in `vLLMSwiftAppTests/`

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines
- Follow existing SwiftUI and MVVM patterns
- Add DocC documentation for new public APIs
- Include unit tests for new functionality
- Maintain consistency with existing code style
	
## Acknowledgements

Several open source projects are used in associated with this project:
- [Llama-Stack] https://github.com/meta-llama/llama-stack
- [Alamofire] https://github.com/Alamofire/Alamofire
- [SwiftOpenAI] https://github.com/jamesrochabrun/SwiftOpenAI
- [MacPaw/OpenAI] https://github.com/MacPaw/OpenAI
