# CmdHere - Delphi IDE Extension

> A productivity-enhancing Delphi IDE extension that adds convenient "Open CMD here" functionality to the Project Manager context menu.

A Delphi IDE extension that adds a context menu option "Open CMD here" to the Project Manager, allowing you to quickly open a command prompt in the folder of the selected project, file, or directory.

## 🚀 Why CmdHere?

Streamline your development workflow by eliminating the need to manually navigate to project folders in the command line. With CmdHere, you can instantly open a command prompt in the exact location you're working on, directly from the Delphi IDE Project Manager.

## ✨ Features

- **Context Menu Integration**: Adds "Open CMD here" option to Project Manager context menu
- **Multi-Selection Support**: Works with multiple selected items
- **Smart Folder Detection**: Automatically determines the appropriate folder based on the selected item:
  - For files: Opens CMD in the file's directory
  - For projects: Opens CMD in the project's directory
  - For directories: Opens CMD in the selected directory
  - For project groups: Opens CMD in the project group's directory

## 📦 Installation

### Quick Install (Recommended)

1. Download the latest release from the [Releases page](https://github.com/tonipuh/CmdHere/releases)
2. Open the Delphi IDE
3. Go to **Component** → **Install Packages...**
4. Click **Add...** and browse to the compiled package file (`.bpl`)
5. Click **OK** to install the package

### Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/tonipuh/CmdHere.git
   ```
2. Open `CmdHereProjectManager.dpk` in Delphi
3. Right-click the project and select **Compile**
4. Right-click the project and select **Install**

## 🎯 Usage

1. **Right-click** on any item in the Project Manager:
   - 📄 Files
   - 📁 Directories  
   - 🔷 Projects
   - 🗂️ Project Groups

2. **Select** "Open CMD here" from the context menu

3. **Enjoy** instant command prompt access in the correct directory!

### Example Scenarios

- Working with version control commands (`git`, `svn`)
- Running build scripts or batch files
- Quick file operations (`dir`, `copy`, `move`)
- Package management (`npm`, `pip`, etc.)
- Custom development tools

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

## 📋 Requirements

- **Delphi IDE** (tested with modern versions: 10.x+)
- **Windows** operating system
- **Design-time package** installation capability

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **🐛 Report Issues**: Found a bug? [Create an issue](https://github.com/tonipuh/CmdHere/issues)
2. **💡 Suggest Features**: Have an idea? [Start a discussion](https://github.com/tonipuh/CmdHere/discussions)
3. **🔧 Submit PRs**: 
   - Fork the repository
   - Create a feature branch (`git checkout -b feature/amazing-feature`)
   - Commit your changes (`git commit -m 'Add amazing feature'`)
   - Push to the branch (`git push origin feature/amazing-feature`)
   - Open a Pull Request

## 📝 License

This project is provided as-is for educational and development purposes.

## ⭐ Show Your Support

If this extension helps your development workflow, please consider:
- ⭐ Starring this repository
- 🐛 Reporting issues you encounter
- 📢 Sharing it with other Delphi developers

## 📈 Version History

- **v1.1.0**: Delphi 13 / 13.1 support
  - Builds for both Win32 and Win64 IDE (64-bit IDE requires Win64 package)
  - New "Open Windows Terminal here" menu item (shown when `wt.exe` is on PATH)
  - Uses `IOTAProjectCurrentFolder` to resolve project directory when the project supports it, with fallback to `Project.FileName`
  - Fixed `LooksLikePath` to accept UNC paths; switched folder/file checks to `System.IOUtils`
  - Proper notifier lifecycle: `RemoveMenuItemCreatorNotifier` is now called in the unit's `finalization`, preventing dangling references on package unload
  - Simplified `.dproj` to Windows-only platforms (Win32 + Win64), removed Android/iOS/Linux/macOS/Win64x noise
- **v1.0.0**: Initial release with "Open CMD here" functionality and multi-selection support

---

<p align="center">
  Made with ❤️ for the Delphi community
</p>
