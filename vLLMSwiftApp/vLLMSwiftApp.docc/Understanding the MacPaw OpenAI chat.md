# Understanding the MacPaw OpenAI chat

Learn about implementing text chat functionality using MacPaw OpenAI

## Overview

[MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) is a community-maintained Swift implementation of the OpenAI public API, released under the MIT license. This article focuses on how the MacPaw OpenAI SDK is used to interact with models served by vLLM using an OpenAI-compatible endpoint.

MacPaw/OpenAI project documentation can be accessed on the main GitHub page of the project. The OpenAI specification that the SDK implements can be found on the [OpenAI Platform website](https://platform.openai.com/docs/guides/text?api-mode=responses).

>Important: You must have access to an OpenAI-compatible or Llama-Stack server (with OpenAI compatibility) for the SDK to connect. There are many providers of inference server with OpenAI-compatible endpoints. vLLM is one such inference server, and [documentation on how to implement an OpenAI-compatible endpoint](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is available in the vLLM project documentation.

### User interface

The user interface for interacting with vLLM for inference using an OpenAI-endpoint via MacPaw OpenAI is contained within ``MacPawOpenAIChatView``. That view leverages a subview called ``ChatInputView`` that provides an API agnostic method for collecting the user prompt to send for inference. The MVVM model for ``MacPawOpenAIChatView`` is contained within ``MacPawOpenAIChatViewModel``.

``MacPawOpenAIChatView`` is made visible by the ``MainAppView`` when the user selects the **MacPaw → OpenAI Chat** menu option from the main menu on the left sidebar of the app.

### Implementation details

The MacPaw OpenAI implementation demonstrates several key architectural features:

- **High-level SDK integration**: Uses the MacPaw OpenAI library's `OpenAI.Configuration` and streaming chat completion methods
- **Flexible configuration**: Supports custom host, port, scheme, and base path configuration for non-OpenAI servers
- **Streaming responses**: Processes real-time streaming responses using `chatsStream()` with async/await patterns
- **Comprehensive error handling**: Handles both MacPaw SDK-specific errors and network-level issues with detailed error categorization
- **Real-time updates**: Leverages the `@Observable` macro for immediate UI updates as streaming content arrives
- **URL path correction**: Automatically sets base path to `/v1` if no path is provided in the server URL

### Key components

The implementation includes several important elements:

- `OpenAI.Configuration`: Flexible configuration object supporting custom endpoints beyond OpenAI's servers
- `ChatQuery`: Type-safe request structure with messages and model configuration
- `chatsStream()`: Async streaming method that returns real-time chat completion chunks
- `macPawOpenAIInferenceError`: Custom error enum covering invalid URLs, API errors, and network issues
- Finish reason handling: Processes completion states like `stop`, `length`, `contentFilter`, and tool calls

### Error handling

The MacPaw OpenAI implementation provides sophisticated error handling across multiple layers:

- **SDK-level errors**: Catches and interprets `OpenAIError` instances with HTTP status code extraction
- **API-level errors**: Handles specific OpenAI error codes (400, 401, 429, 503) with appropriate descriptions
- **Network-level errors**: Processes connection failures and timeouts with user-friendly messages
- **Completion errors**: Interprets finish reasons like content filtering and token limits as actionable errors

### Configuration flexibility

The implementation showcases the MacPaw SDK's flexibility for non-OpenAI endpoints:

- Custom host and port configuration for local or alternative servers
- Configurable scheme (HTTP/HTTPS) and base path settings
- Optional API key handling for servers that don't require authentication
- Timeout interval customization for different server response times

### Testing

Swift Testing code for MacPaw OpenAI functionality is located in the vLLMSwiftAppTests folder of the project. Currently test coverage includes:
- ``MacPawOpenAIChatViewModel``

