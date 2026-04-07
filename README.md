# Gym Management System

A C# WPF desktop application for managing gym memberships, backed by a MySQL database.

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| Visual Studio 2022 | Build and run the WPF app |
| .NET 8.0 SDK | Installed automatically with VS 2022 |
| MySQL Server 8.x | Local database engine |
| MySQL Workbench | Run the SQL setup script |

---

## Step 1 — Run GymDB.sql in MySQL Workbench

This script creates the database, all tables, and loads sample data.

1. Open **MySQL Workbench** and connect to your local server (`localhost`, user `root`).
2. In the menu bar choose **File → Open SQL Script…**
3. Navigate to the project folder and select **`GymDB.sql`**.
4. Click the **lightning bolt** icon (Execute) or press **Ctrl+Shift+Enter** to run the entire script.
5. In the **Schemas** panel on the left, right-click and choose **Refresh All** — you should see **GymDB** appear with three tables:
   - `Members`
   - `MembershipPlans`
   - `Payments`

> **Tip:** If you see an error like `Table 'gymdb.members' doesn't exist`, make sure the script ran from the top (the `CREATE DATABASE` and `USE GymDB` lines must execute first). Select all with **Ctrl+A** and re-run.

---

## Step 2 — Set the MySQL Password in DatabaseHelper.cs

The app connects using the credentials in `DatabaseHelper.cs`.

1. Open **`DatabaseHelper.cs`** in Visual Studio.
2. Find line 9 — the connection string:

```csharp
private const string ConnectionString =
    "Server=localhost;Database=GymDB;Uid=root;Password=;";
```

3. Replace the empty `Password=` value with your root password:

```csharp
private const string ConnectionString =
    "Server=localhost;Database=GymDB;Uid=root;Password=YOUR_PASSWORD_HERE;";
```

4. Save the file (**Ctrl+S**).

> **No password set?** Leave `Password=;` as-is — this is the default for a fresh MySQL installation.

---

## Step 3 — Restore NuGet Packages in Visual Studio

The project depends on the **MySql.Data** package. Visual Studio can restore it automatically.

**Option A — Automatic on Build (recommended)**

1. Open `GymManagementApp.sln` in Visual Studio 2022.
2. Press **Ctrl+Shift+B** (Build Solution).
3. Visual Studio will detect the missing package and restore it before compiling. Watch the **Output** panel for `Restored MySql.Data`.

**Option B — Manual Restore via Package Manager Console**

1. Go to **Tools → NuGet Package Manager → Package Manager Console**.
2. Run:
   ```
   Update-Package -reinstall
   ```

**Option C — Manual Restore via Solution Explorer**

1. In **Solution Explorer**, right-click the solution node (topmost item).
2. Choose **Restore NuGet Packages**.
3. Wait for the status bar to show `Ready`.

> **Still missing?** Go to **Tools → Options → NuGet Package Manager → General** and enable **Allow NuGet to download missing packages**.

---

## Step 4 — Build and Run

1. Set the startup project to **GymManagementApp** (right-click → Set as Startup Project) if not already set.
2. Press **F5** (Debug) or **Ctrl+F5** (Run without debugging).
3. The app opens on the **View Members** page — the DataGrid auto-populates from the database.

---

## Project Structure

```
GymManagementApp/
├── GymManagementApp.sln       # Visual Studio solution
├── GymManagementApp.csproj    # Project file (.NET 8 WPF)
├── GymDB.sql                  # Database schema, sample data, and study queries
├── DatabaseHelper.cs          # MySQL connection and all CRUD operations
├── App.xaml / App.xaml.cs     # Application entry point
├── MainWindow.xaml/.cs        # Navigation shell
├── ViewMembers.xaml/.cs       # Member directory with search and DataGrid
└── ManageMembers.xaml/.cs     # Add / Update / Delete form
```

---

## Pages

### View Members
- Loads all members from the database on startup.
- Search by **Member ID**, **First Name**, or **Last Name** (any combination).
- Results display in the DataGrid; empty search fields are ignored.

### Manage Members
- **ADD** — Enter a full name (`First Last`), phone, and membership type, then click ADD.
- **UPDATE** — Enter the Member ID of an existing record, fill in the new values, click UPDATE.
- **DELETE** — Enter the Member ID and click DELETE; a confirmation dialog appears first.
- **RESET** — Clears all form fields.

---

## GymDB.sql Query Reference

The SQL file includes 11 annotated queries covering every topic required for the school project:

| Section | Concepts Covered |
|---------|-----------------|
| A | `SELECT *`, basic column selection |
| B | `WHERE` with `=` equality filter |
| C | `WHERE` with `LIKE` and `OR` for partial-text search |
| D | `ORDER BY ASC / DESC` |
| E | `INNER JOIN` across three tables |
| F | `LEFT JOIN` with `COALESCE` for NULL handling |
| G | Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| H | `GROUP BY` combined with `ORDER BY` on an aggregate |
| I | `HAVING` to filter aggregated groups |
| J | Subquery with `IN` and a scalar subquery |
| K | Correlated subquery with `NOT EXISTS` |
| L | Date functions: `BETWEEN`, `DATE_ADD`, `DATE_FORMAT` |
