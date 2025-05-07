# Understanding basic application structure

Learn about the basic structure of the application

## Overview

The goal of the application is to provide an example of how to implement a simple chatbot that will connect to a vLLM server and make a text inference request. The two connectivity options that are used for the call from the application to vLLM are Llama-Stack and OpenAPI.

>Note: Only the Llama-Stack remote inference API call is currently implemented. 

Application functionality can be broken down into three major categories:
- **Server definition and maintenance:** allows the user to create, update, and delete the server definitions that are require to make inference requests.
- **Specify what API to use per server:** use Llama-Stack or OpenAI APIs when sending a request (prompt) for model inference.
- **Submit text inference requests and handle responses:** as well as see the history of interactions with the model.

### Application startup

When the application starts it performs three basic tasks
- Define the Swift Data schema, and attach the container to the ``MainAppView``.
- Configure the TipKit framework using ``ApplicationTipConfiguration``.
- Create the base application user interface via the view defined in ``MainAppView``.


### Application data

Swift Data is used to persist data across application launches. The only persistent data implemented at this time is the list of servers that the application can connect to. The exact data that is stored for each server can be found in ``Server``.

> Warning: Persistent data maintained for Tips is automatically managed by TipKit. The code in ``vLLMSwiftApp/vLLMSwiftApp/init()`` contains the line try? Tips.resetDatastore() that resets the tips data store so that usage info isn't persisted across app usage. You must remove this line to test tip functionality as it will behave during recurring usage of the application.

### Initial application execution

When the application starts up, the ``MainAppView`` appears and is responsible for defining the NavigationSplitView that is the base structure for the user interface. The left sidebar contains a menu with items enable based on application state, and code availability.

Code availability simply means that the view and code associated with a menu item has been created. Since this project is being released before all code is completed, there will be menu items that can't be used. Determining what menu items are available in code is based on the contents of NavItem and NavItem/destination, that is either set to a nil value, or one of the enumerations in DynamicNavigationDestination. Nil values indicate no code is available for the NavItem. The code in ``MainAppView/body`` determines if there is a value, and if so creates a NavigationLink for it.

When the ``MainAppView`` appears, the code will check to see if there are any servers defined. If there aren't any, then the menu item labeled "vLLM Severs" will be selected, and the ``ServerListView`` will appear in the detail column of the NavigationSplitView. In addition, the tip in ``CreateServerTip`` will be displayed underneath the plus symbol in the toolbar on the upper right of the window. 

### Server list management

The user must define one or more servers to connect to in the application before any other functionality can be used. The user can manage (create, update, delete) server via the "vLLM Servers" menu item that shows the ``ServerListView`` in the detail column of the NavigationSplitView.  

The view is comprised of a list of known servers that are persisted in Swift Data. New servers can be added by clicking the plus symbol shown on the upper right of the application. Existing servers can be edited by clicking on them in the list, and deleted when selected in the list **and** the pressing the minus symbol on the upper right of the app window.

When a server is added or is being edited a SwiftUI Inspector sheet will appear on the right side of the application window. The content and functionality of the inspector are defined in ``ServerEditView``. 

### vLLM inference (chat) interactions
There are multiple views that allow for interaction with a vLLM server. Interaction is performed using either LLama-Stack or OpenAI REST APIs. There are articles available for the following application menu items: 

**Llama-Stack**

- Llama-Stack Chat - review the <doc:Understanding-the-Llama-Stack-chat> article

**OpenAI**

- No implementations or associated articles at this time
