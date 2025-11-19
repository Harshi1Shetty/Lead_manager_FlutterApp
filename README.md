# Lead Manager

A simple lead management application built with Flutter to demonstrate CRUD operations, state management, and other common app features.

## App Overview

This is a mini-application designed to manage sales or business leads. Key features include:

- **CRUD Operations:** Create, Read, Update, and Delete leads.
- **Local Storage:** Persists leads locally using an SQLite database.
- **State Management:** Uses the `provider` package for efficient state management.
- **Dark & Light Mode:** Theme toggling for user preference.
- **Pagination/Lazy Loading:** Leads are loaded in pages for better performance.
- **Search:** Filter leads by name.
- **JSON Export:** Export all leads to a JSON file and share it.
- **Simple UI Animations:** Subtle animations for a better user experience.

## How to Run

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd lead_manager
    ```

2.  **Install dependencies:**
    Make sure you have the Flutter SDK installed. Run the following command in the project root:
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    Connect a device or start an emulator, then run:
    ```bash
    flutter run
    ```

## Architecture Explanation

The app follows a simple and scalable architecture pattern using the `provider` package for state management.

-   **`main.dart`**: The entry point of the application. It sets up `MultiProvider` to make the `LeadProvider` and `ThemeProvider` available throughout the widget tree. It also configures the light and dark themes.

-   **`providers/`**: This directory holds the application's state.
    -   `lead_provider.dart`: Manages the state of the leads, including loading, adding, updating, deleting, searching, and exporting. It communicates with the `DatabaseHelper` to persist data.
    -   `theme_provider.dart`: Manages the app's theme (light/dark mode).

-   **`services/`**: Contains the business logic for interacting with external services, in this case, the local database.
    -   `database_helper.dart`: A singleton class that handles all SQLite database operations (CRUD). It's responsible for creating the database, tables, and handling all queries.

-   **`models/`**: Defines the data structures.
    -   `lead.dart`: The data model for a single lead, including methods for converting to/from a map for database storage.

-   **`screens/`**: Contains the UI for different parts of the application.
    -   `home_screen.dart`: The main screen that displays the list of leads, handles pagination, and provides access to search, theme toggling, and export features.
    -   `add_edit_lead_screen.dart`: A form for creating a new lead or editing an existing one.
    -   `lead_detail_screen.dart`: Displays the details of a selected lead.

-   **`utils/`**: Contains utility files and constants.
    -   `constants.dart`: Holds shared constants like colors for different lead statuses.

## Packages Used

-   **`provider`**: For dependency injection and state management.
-   **`sqflite`**: A Flutter plugin for SQLite, used for local data persistence.
-   **`path`**: Used to construct the database file path.
-   **`path_provider`**: To find the correct local path for storing the exported JSON file.
-   **`share_plus`**: To enable sharing the exported JSON file with other apps.
-   **`flutter`**: The core framework.
-   **`cupertino_icons`**: For iOS-style icons.
