# Understanding the SwiftOpenAI chat

Learn about implementing text chat functionality using SwiftOpenAI

## Overview

[SwiftOpenAI](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is an a open source project under the MIT license. This article focuses on how the SwiftOpenAI SDK is used to interact with models served by vLLM using an OpenAI-compatible endpoint. 

Project documentation can be accessed on the main page of the SwiftOpenAI project. The OpenAI specification that the SDK is based on can be found on the [OpenAI Platform website](https://platform.openai.com/docs/guides/text?api-mode=responses)

>Important: You must have access to an OpenAI-compatible or Llama-Stack server (with OpenAI compatibility) for the SDK to connect. There are many providers of inference server with OpenAI-compatible endpoints. vLLM is one such inference server, and [documentation on how to implement an OpenAI-compatible endpoint](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is available in the vLLM project documentation.

### User interface

The user interface for interacting with vLLM for inference using an OpenAPI-endpoint, and SwiftOpenAI, is contained within ``SwiftOpenAIChatView``. That view leverages a subview called ``ChatInputView`` that provides an API agnostic method for collecting the user prompt to send for inference. The MVVM model for ``SwiftOpenAIChatView`` is contained within ``SwiftOpenAIChatViewModel``.

``SwiftOpenAIChatView`` is made visible by the ``MainAppView`` when the user selects the **SwiftOpenAI Chat** menu option from the main menu on the left sidebar of the app.

### Testing

Swift Testing code for the SwiftOpenAI functionality is located in the vLLMSwiftAppTests folder of the project. Currenty test coverage includes:
- ``SwiftOpenAIChatViewModel``

> Important: Testing of server connectivity is performed using actual URLs instead of server stubs. Until stubs are created in the test code, you will need to modify the test URLs to match your environment before the tests can pass.
