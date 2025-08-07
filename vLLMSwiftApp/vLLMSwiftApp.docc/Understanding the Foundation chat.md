# Understanding the Foundation chat

Learn about implementing text chat functionality using Foundation URLSession

## Overview

This implementation uses Apple's native [URL Loading System](https://developer.apple.com/documentation/foundation/httpurlresponse) from the Foundation framework to interact with models served by vLLM using an OpenAI-compatible endpoint. The Foundation framework is Apple's core framework that provides fundamental functionality for all iOS and macOS applications.

Foundation's URL Loading System provides a robust, built-in solution for HTTP networking without requiring external dependencies. The OpenAI specification that this implementation follows can be found on the [OpenAI Platform website](https://platform.openai.com/docs/guides/text?api-mode=responses).

>Important: You must have access to an OpenAI-compatible or Llama-Stack server (with OpenAI compatibility) for the implementation to connect. There are many providers of inference server with OpenAI-compatible endpoints. vLLM is one such inference server, and [documentation on how to implement an OpenAI-compatible endpoint](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is available in the vLLM project documentation.

### User interface

The user interface for interacting with vLLM for inference using an OpenAI-endpoint via Foundation URLSession is contained within ``FoundationChatView``. That view leverages a subview called ``ChatInputView`` that provides an API agnostic method for collecting the user prompt to send for inference. The MVVM model for ``FoundationChatView`` is contained within ``FoundationChatViewModel``.

``FoundationChatView`` is made visible by the ``MainAppView`` when the user selects the **URLSession Chat** menu option from the main menu on the left sidebar of the app.

### Implementation details

The Foundation implementation demonstrates several key architectural features:

- **Native networking**: Uses Apple's built-in ``URLSession`` for HTTP communications, eliminating external dependencies
- **Streaming responses**: Processes server-sent events (SSE) using ``URLSession.AsyncBytes`` for real-time response streaming
- **Comprehensive error handling**: Handles both low-level network errors (``URLError``) and OpenAI API-specific errors
- **Modular design**: Separates URL request preparation, session setup, and response processing into distinct methods
- **Real-time updates**: Leverages the `@Observable` macro for immediate UI updates as streaming content arrives
- **URL validation**: Automatic URL path correction (adds `/v1/chat/completions` if no path is provided)

### Key components

The implementation includes several important structures and methods:

- ``OpenAIRequest``: Represents the request payload sent to the OpenAI-compatible endpoint
- ``OpenAIMessage``: Represents individual messages in the conversation
- ``OpenAIStreamResponse``: Handles the streaming response format from the server
- ``OpenAIError`` and ``OpenAIErrorResponse``: Capture and process error responses from the API
- `prepareURLRequest(forPrompt:onServer:)`: Creates properly configured URLRequest instances
- `setupURLSession(request:)`: Manages URLSession creation with comprehensive error handling
- `processChatCompletionChunk(responseString:httpResponseCode:)`: Processes individual streaming response chunks

### Error handling

The Foundation implementation provides robust error handling across multiple layers:

- **Network-level errors**: Handles connection failures, timeouts, and DNS resolution issues
- **HTTP-level errors**: Processes status codes and server responses
- **API-level errors**: Interprets OpenAI-specific error responses and finish reasons
- **Data-level errors**: Manages JSON decoding and malformed response handling

### Testing

Testing of the Foundation functionality is planned for future implementation. When available, test coverage will be located in the vLLMSwiftAppTests folder of the project.

> Important: When testing is implemented, server connectivity tests will initially be performed using actual URLs instead of server stubs. Until stubs are created in the test code, you will need to modify the test URLs to match your environment before the tests can pass.
