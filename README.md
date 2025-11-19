# CmdHere - Delphi IDE Extension

A Delphi IDE extension that adds a context menu option "Open CMD here" to the Project Manager, allowing you to quickly open a command prompt in the folder of the selected project, file, or directory.

## Features

- **Context Menu Integration**: Adds "Open CMD here" option to Project Manager context menu
- **Multi-Selection Support**: Works with multiple selected items
- **Smart Folder Detection**: Automatically determines the appropriate folder based on the selected item:
  - For files: Opens CMD in the file's directory
  - For projects: Opens CMD in the project's directory
  - For directories: Opens CMD in the selected directory
  - For project groups: Opens CMD in the project group's directory

## Installation

1. Open the Delphi IDE
2. Go to **Component** → **Install Packages...**
3. Click **Add...** and browse to the compiled package file (`.bpl`)
4. Click **OK** to install the package

Alternatively, you can compile and install from source:

1. Open `CmdHereProjectManager.dpk` in Delphi
2. Right-click the project and select **Compile**
3. Right-click the project and select **Install**

## Usage

1. Right-click on any item in the Project Manager (file, project, directory, etc.)
2. Select **"Open CMD here"** from the context menu
3. A command prompt will open in the appropriate directory

## Technical Details

### Package Structure

- **CmdHereProjectManager.dpk**: Delphi package file
- **CmdHereWizard.pas**: Main implementation unit

### Dependencies

- `rtl` - Runtime Library
- `vcl` - Visual Component Library
- `designide` - Design-time IDE interfaces (contains ToolsAPI)

### Key Components

- **TCmdHerePMCreator**: Implements `IOTAProjectMenuItemCreatorNotifier` to add menu items
- **TCmdHereLocalMenu**: Implements the context menu functionality
- **OpenCmdHere**: Core function that launches the command prompt
- **ResolveClickedFolder**: Smart folder resolution based on selection context

## Code Structure

The extension uses Delphi's ToolsAPI to integrate with the IDE:

```pascal
// Main interfaces implemented
IOTAProjectMenuItemCreatorNotifier  // Menu creation
IOTALocalMenu                       // Menu properties
IOTAProjectManagerMenu             // Menu execution
```

## Supported Contexts

The extension intelligently handles different Project Manager contexts:

- **FileContainer**: Files in the project
- **ProjectContainer**: Project nodes
- **ProjectGroupContainer**: Project group nodes
- **DirectoryContainer**: Directory nodes

## Requirements

- Delphi IDE (tested with modern versions)
- Windows operating system
- Design-time package installation capability

## License

This project is provided as-is for educational and development purposes.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this extension.

## Version History

- **Initial Version**: Basic "Open CMD here" functionality with multi-selection support
