# Understanding the Llama-Stack chat

Learn about implementing text chat functionality using Llama-Stack

## Overview

[Llama-Stack](https://github.com/meta-llama/llama-stack) is Meta's standardized interface for Large Language Model applications that provides a unified API for inference, safety, and agentic capabilities. This article focuses on how the Llama-Stack inference API is used to interact with models served by vLLM through the official Swift client library.

The Llama-Stack API can be reviewed in the [API Reference section](https://llama-stack.readthedocs.io/en/latest/references/api_reference/index.html) of the Llama-Stack project documentation. The [source YAML for the API](https://github.com/meta-llama/llama-stack/blob/main/docs/_static/llama-stack-spec.yaml) in OpenAPI 3.1.0 format is also available.

>Important: You must have access to a Llama-Stack server for the API to connect to. If you need to set up a server for the first time, the [Llama-Stack documentation](https://llama-stack.readthedocs.io/en/latest/getting_started/detailed_tutorial.html#step-1-installation-and-setup) can guide you on how to set up a server. You may also need to read about how to [set up vLLM as an inference provider for Llama-Stack](https://blog.vllm.ai/2025/01/27/intro-to-llama-stack-with-vllm.html).

### User interface

The user interface for interacting with the Llama-Stack server that in turn interacts with vLLM for inference is contained within ``LlamaStackChatView``. That view leverages a subview called ``ChatInputView`` that provides an API agnostic method for collecting the user prompt to send for inference. The MVVM model for ``LlamaStackChatView`` is contained within ``LlamaStackChatViewModel``.

``LlamaStackChatView`` is made visible by the ``MainAppView`` when the user selects the **Llama-Stack Chat** menu option from the main menu on the left sidebar of the app.

### Implementation details

The Llama-Stack implementation demonstrates several key architectural features:

- **Official SDK integration**: Uses the [llama-stack-client-swift SDK](https://github.com/meta-llama/llama-stack-client-swift) for type-safe API interactions
- **Contract-first development**: Built against the official Llama-Stack API specification using auto-generated code
- **Streaming responses**: Processes real-time streaming responses using async/await patterns with `RemoteInference`
- **Multi-content support**: Handles text, image, and tool call content types through the delta streaming interface
- **Real-time updates**: Leverages the `@Observable` macro with explicit `MainActor` dispatching for thread-safe UI updates
- **Comprehensive error handling**: Includes custom `LlamaStackError` enum for various failure scenarios

### Key components

The implementation includes several important elements:

- ``RemoteInference``: The primary client class from the LlamaStack SDK for making inference requests
- `Components.Schemas.ChatCompletionRequest`: Type-safe request structure with model ID, messages, and streaming configuration
- `Components.Schemas.UserMessage`: Structured message format supporting interleaved content types
- `LlamaStackError`: Custom error enum covering invalid server types, missing URLs, and API errors
- Async streaming with `for await chunk` pattern for processing delta responses

### SDK architecture

The Llama-Stack project employs a contract-first development approach where the API specification is defined before code development. This has important implications:

- The [llama-stack-client-swift SDK](https://github.com/meta-llama/llama-stack-client-swift) is designed for compatibility with specific API specification versions
- A significant portion of the SDK code is automatically generated using the [Swift OpenAPI Generator project](https://github.com/apple/swift-openapi-generator)
- Local code generation occurs as part of the Xcode build process via plugins
- The SDK provides high-level classes that simplify usage of the generated API code

>Note: The llama-stack-client-swift SDK version used for this code is 0.2.2, which currently implements a subset of the Agents and Inference endpoints in the overall Llama-Stack API. As the SDK evolves and matures, it will implement more of the Llama-Stack API specification.

### Testing

Testing of the Llama-Stack functionality is planned for future implementation. When available, test coverage will be located in the vLLMSwiftAppTests folder of the project.

> Important: When testing is implemented, server connectivity tests will initially be performed using actual URLs instead of server stubs. Until stubs are created in the test code, you will need to modify the test URLs to match your environment before the tests can pass.




