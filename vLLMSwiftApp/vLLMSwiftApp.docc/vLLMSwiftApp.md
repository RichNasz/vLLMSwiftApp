# ``vLLMSwiftApp``

@Metadata {
	@DisplayName("vLLM Swift Application (vLLMSwiftApp)")
}
@Options {
	@TopicsVisualStyle(list)
}


Sample application that demonstrates how to connect to vLLM using Llama-Stack or OpenAI APIs.

## Overview

The source code in this project demonstrates how to make a remote inference call to vLLM within a SwiftUI application that can run on macOS or iOS.

### What is vLLM?

vLLM is an inference engine capable of providing multiple ways that applications can interact with it for inference requests:
1. the OpenAI-compatible Completions API & Chat API which provides a widely used and flexible interface for sending prompts and receiving responses
2. the newly introduced Llama-Stack API which promises standardized access to many advanced generative AI features including inference. 

>Tip: Full documentation for the vLLM server open source project can be found [at this link](https://docs.vllm.ai/en/latest/)

## Topics

### Basic application structure

- <doc:Understanding-basic-application-structure>
- ``vLLMSwiftApp/vLLMSwiftApp``
- ``MainAppView``
- ``ApplicationTipConfiguration``
- ``CreateServerTip``
- ``ChooseMenuItemTip``

### Common code components
- <doc:Understanding-common-code-components>

- ``ChatMessage``
- ``ChatInputView``
- ``ChatInputView``

- ``Server``
- ``ServerListView``
- ``ServerEditView``
- ``CreateServerTip``


### Llama-Stack Chat
- <doc:Understanding-the-Llama-Stack-chat>
- ``LlamaStackChatView``
- ``LlamaStackChatViewModel``

### SwiftOpenAI Chat
- <doc:Understanding-the-SwiftOpenAI-chat>
- ``SwiftOpenAIChatView``
- ``SwiftOpenAIChatViewModel``

### MacPaw/OpenAI Chat
- <doc:Understanding-the-MacPaw-OpenAI-chat>
- ``MacPawOpenAIChatView``
- ``MacPawOpenAIChatViewModel``

