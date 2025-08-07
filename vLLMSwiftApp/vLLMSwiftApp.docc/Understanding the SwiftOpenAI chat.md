# Understanding the SwiftOpenAI chat

Learn about implementing text chat functionality using SwiftOpenAI

## Overview

[SwiftOpenAI](https://github.com/jamesrochabrun/SwiftOpenAI) is an open source Swift library released under the MIT license that provides a comprehensive implementation of the OpenAI API. This article focuses on how the SwiftOpenAI SDK is used to interact with models served by vLLM using an OpenAI-compatible endpoint.

Project documentation can be accessed on the main GitHub page of the SwiftOpenAI project. The OpenAI specification that the SDK implements can be found on the [OpenAI Platform website](https://platform.openai.com/docs/guides/text?api-mode=responses).

>Important: You must have access to an OpenAI-compatible or Llama-Stack server (with OpenAI compatibility) for the SDK to connect. There are many providers of inference server with OpenAI-compatible endpoints. vLLM is one such inference server, and [documentation on how to implement an OpenAI-compatible endpoint](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is available in the vLLM project documentation.

### User interface

The user interface for interacting with vLLM for inference using an OpenAI-endpoint via SwiftOpenAI is contained within ``SwiftOpenAIChatView``. That view leverages a subview called ``ChatInputView`` that provides an API agnostic method for collecting the user prompt to send for inference. The MVVM model for ``SwiftOpenAIChatView`` is contained within ``SwiftOpenAIChatViewModel``.

``SwiftOpenAIChatView`` is made visible by the ``MainAppView`` when the user selects the **SwiftOpenAI Chat** menu option from the main menu on the left sidebar of the app.

### Implementation details

The SwiftOpenAI implementation demonstrates several key architectural features:

- **Factory-based service creation**: Uses `OpenAIServiceFactory.service()` to create configured `OpenAIService` instances with custom base URLs
- **Flexible configuration**: Supports custom endpoint URLs and optional API key authentication for non-OpenAI servers
- **Streaming responses**: Processes real-time streaming responses using `startStreamedChat()` with async/await patterns
- **Type-safe parameters**: Uses `ChatCompletionParameters` with structured message formatting and custom model specification
- **Comprehensive error handling**: Handles both SwiftOpenAI SDK-specific errors and general network issues
- **Real-time updates**: Leverages the `@Observable` macro for immediate UI updates as streaming content arrives
- **URLSession configuration**: Supports custom timeout intervals and networking configuration

### Key components

The implementation includes several important elements:

- `OpenAIServiceFactory`: Factory class for creating configured `OpenAIService` instances with custom endpoints
- `OpenAIService`: Primary service class for making OpenAI API requests with streaming support
- `ChatCompletionParameters`: Type-safe parameter structure with messages, model, and configuration options
- `startStreamedChat()`: Async streaming method that returns real-time chat completion chunks
- `swiftOpenAIInferenceError`: Custom error enum covering invalid URLs, API errors, and network issues
- `APIError.responseUnsuccessful`: SwiftOpenAI SDK error type for HTTP response failures

### Service factory pattern

The SwiftOpenAI implementation showcases the library's factory pattern for service creation:

- **Custom base URL support**: Allows overriding the default OpenAI endpoint for local or alternative servers
- **Optional API key handling**: Supports servers that don't require authentication by passing empty API keys
- **URLSession configuration**: Enables custom timeout intervals and networking behavior
- **Service reusability**: Created services can be reused for multiple requests with consistent configuration

### Error handling

The SwiftOpenAI implementation provides robust error handling across multiple layers:

- **SDK-level errors**: Catches and interprets `APIError.responseUnsuccessful` with status codes and descriptions
- **Network-level errors**: Handles general networking and connection issues with fallback error messages
- **Parameter validation**: Validates server URLs and model names before making requests
- **Custom error mapping**: Translates SwiftOpenAI errors into application-specific error types

### Testing

Swift Testing code for the SwiftOpenAI functionality is located in the vLLMSwiftAppTests folder of the project. Currently test coverage includes:
- ``SwiftOpenAIChatViewModel``

> Important: Testing of server connectivity is performed using actual URLs instead of server stubs. Until stubs are created in the test code, you will need to modify the test URLs to match your environment before the tests can pass.
