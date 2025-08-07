# ``vLLMSwiftApp``

@Metadata {
	@DisplayName("vLLM Swift Application (vLLMSwiftApp)")
}
@Options {
	@TopicsVisualStyle(list)
}


Comprehensive sample application demonstrating five different approaches to implementing chat interfaces that connect to vLLM servers using various Swift networking libraries and patterns.

## Overview

This project provides a complete showcase of how to implement chat interfaces that connect to vLLM servers within a SwiftUI application that runs on macOS and iOS. The application demonstrates both Llama-Stack API integration and multiple OpenAI-compatible API implementations, each using different networking approaches and architectural patterns.

### What is vLLM?

vLLM is a high-performance inference engine capable of providing multiple ways that applications can interact with it for inference requests:
1. **OpenAI-compatible APIs**: Completions API & Chat API which provide widely used and flexible interfaces for sending prompts and receiving responses
2. **Llama-Stack API**: Newly introduced standardized API that promises unified access to many advanced generative AI features including inference, safety, and agentic capabilities

The application showcases how to connect to vLLM using both API approaches through five distinct implementation strategies, each demonstrating different Swift networking libraries and architectural patterns.

>Tip: Full documentation for the vLLM server open source project can be found [at this link](https://docs.vllm.ai/en/latest/)

## Topics

### Basic application structure

- <doc:Understanding-basic-application-structure>
- ``vLLMSwiftApp/vLLMSwiftApp``
- ``MainAppView``

### Application guidance and tips
- ``ApplicationTipConfiguration``
- ``CreateServerTip``
- ``ChooseMenuItemTip``

### Common code components
- <doc:Understanding-common-code-components>
- ``ChatMessage``
- ``ChatInputView``
- ``Server``
- ``ServerListView``
- ``ServerEditView``

### Llama-Stack implementation
- <doc:Understanding-the-Llama-Stack-chat>
- ``LlamaStackChatView``
- ``LlamaStackChatViewModel``

### OpenAI-compatible implementations

#### Foundation URLSession approach
- <doc:Understanding-the-Foundation-chat>
- ``FoundationChatView``
- ``FoundationChatViewModel``

#### Alamofire HTTP library approach
- <doc:Understanding-the-Alamofire-chat>
- ``AlamoFireChatView``
- ``AlamoFireChatViewModel``

#### SwiftOpenAI SDK approach
- <doc:Understanding-the-SwiftOpenAI-chat>
- ``SwiftOpenAIChatView``
- ``SwiftOpenAIChatViewModel``

#### MacPaw OpenAI SDK approach
- <doc:Understanding-the-MacPaw-OpenAI-chat>
- ``MacPawOpenAIChatView``
- ``MacPawOpenAIChatViewModel``
