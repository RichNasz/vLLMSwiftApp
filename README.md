# vLLMSwiftApp
Sample code to demonstrate implementing a simple chatbot that can connect to vLLM servers using different HTTP REST APIs

vLLM can accept reference requests using the following REST API options:
- OpenAPI-compatible API
- Llama-stack APIEndpointType

## Build Instructions

Follow these steps to build and run the Xcode project in this repository.

### Prerequisites
- **Xcode**: Version 16.3 or later (download from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835) or [Apple web site](https://developer.apple.com/xcode/).
- **macOS**: macOS 15.0 (Sequoia) or later.
- An Apple Developer account (optional, for running on physical devices).

### Clone the repository

1. **Clone using command line**:

You can clone the repository directly into the a directory of your choice using the terminal application and typing in the following:
   ```bash
   git clone https://github.com/RichNasz/vLLMSwiftApp.git
   cd vLLMSwiftApp
   ```
   
Navigate to the cloned folder in the Finder, locate the .xcodeproj or .xcworkspace file, and double-click it to open in Xcode.
Alternatively, in Xcode, go to File > Open, browse to the cloned folder, and select the project file.
   
2. **Clone using Xcode**

You can clone the repository directly within Xcode
   - In Xcode, navigate to **Integrate > Clone...**
	- In the search field type: https://github.com/RichNasz/vLLMSwiftApp.git 
	- In the dialog box that appears, select the main branch, and then press the **Clone** button.
	- In the file picker dialog that appears, select the directory to clone the project into, and then press the **Clone** button.
	- The repository will be cloned, and the project will be opened and ready use.
	
### Xcode housekeeping

There are several actions you need to take to have a smooth experience working with the project in Xcode:
	- During your first build a dialog box asking you to Enable & Trust the OpenAPIGenerator extension will pop up. Select the option to “Trust & Enable” when prompted. If you don’t do this, code for the SDK can’t be generated, and the code won’t work
	- You need to have your Apple developer account set up in Xcode so that projects you work on can be signed. You can create a free Apple Developer account for this, or use an existing account. make sure your developer account is set using the **Settings… -> Accounts** menu option.
	- Clean the build folder using the **Product -> Clean Build Folder…** menu option.
	- Start a new build using the **Product ->Build** menu option. Once completed you will be able to run the application.
	- Generate the documentation for the project by selecting the **Product -> Build Documentation** menu item. Once completed you can access the documentation using the **Help -> Developer Documentation** menu item.
	
 
	

## Acknowledgements

Several open source projects are used in associated with this project:
- [Llama-Stack] https://github.com/meta-llama/llama-stack
- [Alamofire] https://github.com/Alamofire/Alamofire
- [SwiftOpenAI] https://github.com/jamesrochabrun/SwiftOpenAI
- [MacPaw/OpenAI] https://github.com/MacPaw/OpenAI
