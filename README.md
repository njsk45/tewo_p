# TeWo-P
**TeWo-P** is a "Multi^2-PF" (Multiplatform-Multifunctional) Point of Sale (POS) system designed to run on various platforms and adapt easily to different user needs. It is an ambitious open-source alternative to traditional POS systems, featuring modern functionalities and a clean, simple design.

# OBJECTIVES
- **Multi-Platform & Multifunctional:** A POS system accessible on any device.
- **Hybrid Database:** Support for both local and cloud databases.
- **Flexible Licensing:**
  - **Open Source:** Free version for basic sales and inventory management.
  - **Premium:** Advanced functionalities for professional use.
- **Versatile Integration:** APIs for local, remote, and cloud DB models.
- **Continuous Improvement:** Periodic updates for security, functionality, and support.

# BASE FUNCTIONALITIES

### Core Modules
- **Users:** Login, Registration, Logout, Password Management.
- **Inventory:** List, Search, Add, Modify, and Delete products.
- **Sales:** List, Search, Add, Modify, and Delete sales records.
- **Reports:** Generate, Search, and Manage reports.
- **Configuration:** System and User preferences.

### API Capabilities
- **Desktop:** Full remote use for Administrators and Employees.
- **Mobile:** Remote use with specific limitations (e.g., Login and Sales only).

# PROJECT STRUCTURE
The codebase is organized into modular libraries:

- **app_desktop/**: Core code for the desktop application.
  - `ui_desktop.dart`: User interface for the desktop.
  - `setting_up.dart`: Database configuration and setup.
  - `aws_service.dart`: AWS DynamoDB implementation.
- **app_movil/**: Core code for the mobile application.
  - `ui_movil.dart`: User interface for mobile.
  - `db_connector.dart`: Remote database connection logic for mobile.

# HOW DOES THE CODE WORK?

### Platform Detection & Startup
The entry point is `lib/main.dart`, which checks which version of the UI to execute (desktop or mobile).
*Note: Currently, development is focused on the Desktop UI (`lib/app_desktop/ui_desktop.dart`). The Mobile UI is not active.*

### Desktop Initialization Flow
When the script detects the OS as a desktop system, it starts a check to ensure a configuration file (`setts.json`) exists.

1. **First Run (No Configuration):**
   - If `setts.json` does not exist, the main function redirects the user to the Setup Screen (`lib/apis/setting_up.dart`) to configure the database management.
   - Currently, `lib/apis/setting_up.dart` supports **AWS DynamoDB**.
   - The user must enter the DB keys, press the **test button**, and finally save the keys (encrypted format).
   - When setup is finished, `lib/app_desktop/ui_desktop.dart` starts with the `LoginDynamoDBPage`.
   - *Note: For now, users login with hardcoded credentials: `admin` `admin`.*

2. **Standard Run (Configuration Exists):**
   - If `setts.json` exists, the app performs a connection test.
   - **Test OK:** Opens the Login Page. After login, the main page of `lib/app_desktop/ui_desktop.dart` starts.
   - **Test Failed:** Immediately sends the user to a Warning Page (check connection or call DB support).
     - *If connectivity is resolved:* Automatically starts the Login Page.

### Main Interface Features
After logging in, the Desktop UI (`lib/app_desktop/ui_desktop.dart`) presents two main options:
- **Test Connection:** Tests the connection with the Database.
- **Parameters:** Manage settings. Currently limits to choosing the application theme (Dark or Light).

### Continuous Monitoring
The software performs a regular check for connectivity problems (e.g., Wi-Fi or Internet issues).
If disconnected, the software immediately redirects to a warning page until the connection is restored.

# BUSINESS ADAPTATION SYSTEM (PREFIXES)
TeWo-P employs a unique **Prefix System** to dynamically adapt the user interface and available toolsets based on the specific type of business using the software. This logic is controlled primarily by the `bussines_prefix` and `bussines_target` variables managed in the settings.

### How it works:
- **Identification:** When the application loads, it reads the assigned prefix (e.g., `phones_repair`).
- **Interface Tailoring:** Based on this prefix, the software decides which specific modules to load. For instance, a phone repair shop will see different inventory columns and operation buttons compared to a standard retail store.
- **Scalability:** This allows the same core software to power widely different enterprise types (Stores, Workshops, generic Business) without needing separate codebases.

# FUTURE ROADMAP & SECURITY

### 🔒 Enhanced Security Protocols
As we advance through our initial development phases, we are committed to implementing robust, state-of-the-art security measures. While database keys are currently encrypted locally, our future architecture will transition to **serverless protocols**. This evolution ensures that sensitive credentials are managed with the highest level of security, keeping your data safe as we scale.

### 🧩 "Main Plan" Plugins (Coming Soon)
We are building a platform that grows with you. The upcoming **"Main Plan" Plugin System** will revolutionize how you interact with TeWo-P. Users will soon have the power to:
- **Create** custom interface behaviors and workflows.
- **Export** their unique configurations.
- **Share** their innovations with the global community.
This feature aims to democratize the development of POS solutions, allowing every user to contribute to a more versatile and powerful ecosystem.

### PLUGINS Structure (STILL Testing, coming soon)
Grocery Plugin
|
├── manifest.json  
|   └── store_name: "Grocery Store"
|   └── store_prefix: "grocery"
|   └── store_logo: "store_logo.png"
|   └── store_scripts: "grocery_ops","grocery_view"
|
├── frontend/
|   └── grocery_ops.dart       //this will be replaced by a functional plugin script later
|   └── grocery_view.dart      //this will be replaced by a functional plugin script later
|
├── backend/
|   └── grocery_lambda/
|       └── index.js
|       └── package.json
|
└── assets/
    └── store_logo.png

MIT License (see LICENSE)
