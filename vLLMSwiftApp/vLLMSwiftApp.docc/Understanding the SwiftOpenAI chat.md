# Understanding the SwiftOpenAI chat

Learn about implementing text chat functionality using SwiftOpenAI

## Overview

[SwiftOpenAI](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is an a open source project under the MIT license. This article focuses on how the SwiftOpenAI inference SDK is used to interact with models served by vLLM. 

Project documentation can be accessed on the [Github landing page](https://github.com/jamesrochabrun/SwiftOpenAI) of the SwiftOpenAI project. The OpenAI specification that the SDK is base don can be found on the [OpenAI Platform website](https://platform.openai.com/docs/guides/text?api-mode=responses)

>Important: You must have access to an OpenAI-compatible or Llama-Stack server (w/OpenAI compatibility) for the SDK to connect. There are manu providers of inference server s with OpenAI-compatible endpoints. vLLM is one such inference server and [documentation on how to implement an OpenAI-compatible endpoint](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html) is available in the vLLM project documentation.

### User interface

The user interface for interacting with vLLM for inference using OpenAPI-enspoont via SwiftOpenAI is contained within ``SwiftOpenAIChatView``. That view leverages a subview called ``ChatInputView`` that provides an agnostic method for collecting the user prompt to send for inference. The MVVM moel for ``SwiftOpenAIChatView`` is contained within ``SwiftOpenAIChatViewModel``.

