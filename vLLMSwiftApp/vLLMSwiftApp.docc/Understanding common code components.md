# Understanding common code components

Learn about the common code components of the application

## Overview

Reusing code in an application significantly enhances development efficiency, maintainability, and scalability. Additionally, code reuse promotes consistency across the app, ensuring uniform behavior and easier debugging.

### Common user text chat input

A common need in a chatbot is to collect text from the user to send to the vLLM for inference. While the application offers a variety of ways to connect to vLLM, the desire is to allow the user to have a common chat UI experience.
The ``ChatInputView`` is a view dedicated to collecting text input to the user. It is intended to be used as a subview dedicated to connecting to vLLM using a particular API. The ``LlamaStackChatView`` is an example of such a view
``ChatInputView`` performs the following major tasks
- Collects multiline text input from the user
- Allows the user to press an image button to request the text be send to vLLM for inference
- Disables the image button while text is sent to the server for inference, and a response from the server is being received. The icon also changes to a SwiftUI ProgressView during this time
- When the user pressed tje image button to request the text be send to vLLM for inference, the closure method is called and the user text is provided as the sole parameter. It is the responsibility of the calling view to implement the appropriate closure logic.

### Common server list

In order to issue vLLM inference requests, and receive response to those requests, the application must have information on how to connect to vLLM server instances. The application allows the user to specific the parameters needed to connect to servers and persists them across application usage using Swift Data.
The ``ServerEditView`` is provided to show the user a list of known servers. The lists can be added to, and existing server definitions can be edited and deleted. Editing of server parameters is contained within the ``ServerEditView`` that the ``ServerEditView`` calls via a SwiftUI Inspector.

### Common chat history

The history of user inference chat requests, and responses from the server should be consistent across the various chat options. Current a common view for this **is not** implemented. The chat view functionality in ``LlamaStackChatView`` will be extracted into a separate reusable view in a future revision of the code.


