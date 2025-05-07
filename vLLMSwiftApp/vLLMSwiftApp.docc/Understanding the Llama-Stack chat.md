# Llama-Stack chat

Learn about implementing text chat functionality using Llama-Stack

## Overview

This article focuses on how Llama-Stack inference API  is used to interact with models served by vLLM. The Llama-Stack API can be reviewed in the [API Reference section](https://llama-stack.readthedocs.io/en/latest/references/api_reference/index.html) of the Llama-Stack project documentation. 

The [source YAML for the API](https://github.com/meta-llama/llama-stack/blob/main/docs/_static/llama-stack-spec.yaml), in OpenAPI 3.1.0 format is also available. The API consists of two main components:
- **Endpoints:** REST endpoints that clients call and servers implement.
- **Schemas:** Data structures used when interacting with these endpoints.

The Llama-Stack project employs a contract-first development approach. This means that the API specification must be defined and agreed upon before any code development starts. This has implications for Swift developers using the [llama-stack-client-swift SDK]](https://github.com/meta-llama/llama-stack-client-swift), which is designed to be compatible with a particular version of the API specification. This code uses that SDK

>Note: The llama-stack-client-swift SDK version used for this code is 0.2.2, which currently implements a subset of the Agents and Inference endpoints in the overall Llama-Stack API. As the SDK evolves and matures, you should fully expect the SDK to implement more and more of the Llama-Stack API specification.

A significant portion of the llama-stack-client-swift SDK code is automatically generated using the open-source [Swift OpenAPI Generator project](https://github.com/apple/swift-openapi-generator) from the API specification. Local code generation occurs as part of the build for the project via an Xcode plugin. The SDK provides several classes that simplify usage of the generated API code. Both are used in the code.

### User interface

The user interface for interacting with the Llama-Stack server that in turn interacts with vLLM for inference is contained within ``LlamaStackChatView``. That leverages a subview called ``ChatInputView`` that provides an agnostic method for collecting the request from the user to send for inference.




