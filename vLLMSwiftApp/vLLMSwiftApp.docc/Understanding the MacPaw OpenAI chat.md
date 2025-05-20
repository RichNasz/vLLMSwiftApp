# Understanding the MacPaw OpenAI chat

Learn about implementing text chat functionality using MacPaw OpenAI

## Overview

 [MacPaw / OpenAI](https://github.com/MacPaw/OpenAI) is a community-maintained implementation of the OpenAI public API, and released under the under the MIT license . This article focuses on how the MacPaw OpenAI SDK is used to interact with models served by vLLM using an OpenAI-compatible endpoint. 

MacPaw/OpenAI project documentation can be accessed on the main GitHub page of the project. The OpenAI specification that the SDK is created aginst on can be found on the [OpenAI Platform website](https://platform.openai.com/docs/guides/text?api-mode=responses)

>Important: You must have access to an OpenAI-compatible or Llama-Stack server (with OpenAI compatibility) for the SDK to connect. There are many providers of inference server with OpenAI-compatible endpoints. vLLM is one such inference server, and [documentation on how to implement an OpenAI-compatible endpoint](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is available in the vLLM project documentation.

### User interface

The user interface for interacting with vLLM for inference using OpenAPI-endpoint via MacPaw OpenAI is contained within ``MacPawOpenAIChatView``. That view leverages a subview called ``ChatInputView`` that provides an API agnostic method for collecting the user prompt to send for inference. The MVVM model for ``MacPawOpenAIChatView`` is contained within ``MacPawOpenAIChatViewModel``.

``MacPawOpenAIChatView`` is made visible by the ``MainAppView`` when the user selects the **MacPaw -> OpenAI Chat** menu option from the main menu on the left sidebar of the app.


### Testing

Swift Testing code for MacPaw OpenAI functionality is located in the vLLMSwiftAppTests folder of the project. Currenty test coverage includes:
- ``MacPawOpenAIChatViewModel``

> Important: Testing of server connectivity is performed using actual URLs instead of server stubs. Until stubs are created in the test code, you will need to modify the URLs to match your environment.
