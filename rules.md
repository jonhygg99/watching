# 🏄‍♂️ Windsurf Development Guidelines

## 📌 Key Principles

- Write **concise, technical Dart code** with precise examples.
- Apply **functional and declarative programming patterns** where appropriate.
- Prefer **composition over inheritance**.
- Use **descriptive variable names** with auxiliary verbs (`isLoading`, `hasError`).
- Maintain a **clear file structure**:
  - `exported widgets/`
  - `subwidgets/`
  - `helpers/`
  - `static content/`
  - `types/`
  - `providers/`
  - `services/`

---

## 📝 Dart & Flutter Guidelines

### 📚 Syntax & Style

- Always declare **explicit types** — avoid `dynamic`.
- Naming conventions:
  - `PascalCase` for classes.
  - `camelCase` for variables, functions, and methods.
  - `underscores_case` for file and directory names.
  - `UPPERCASE` for environment variables.
- Use **arrow syntax** for simple functions.
- Prefer **expression bodies** for one-liner getters and setters.
- Add **trailing commas** in multi-line argument lists.

### ⚙️ Functions

- Keep functions **short and single-purpose** (less than 20 statements).
- Function names should start with a verb.
- Avoid nested blocks — use **early returns**.
- Leverage **higher-order functions** (`map`, `filter`, `reduce`).

### 📦 Project Structure

- Follow **Clean Architecture**: divide into `modules/`, `controllers/`, `services/`, `repositories/`, `entities/`.
- Use the **Repository Pattern** for data persistence.
- Implement **GoRouter** or **auto_route** for navigation and deep linking.

---

## 📱 Flutter-Specific Rules

- Use `const` widgets whenever possible.
- Use **ListView.builder** for large lists.
- Prefer **stateless widgets**:
  - `ConsumerWidget` with Riverpod.
  - `HookConsumerWidget` when combining Flutter Hooks.
- Optimize with **AssetImage** for local assets and `cached_network_image` for remote images.

---

## 📊 Riverpod & State Management

- Use `@riverpod` annotation to generate providers.
- Prefer `AsyncNotifierProvider` and `NotifierProvider`.
- Avoid `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider`.
- Use `ref.invalidate()` to manually trigger provider updates.
- Cancel asynchronous operations properly when disposing widgets.
- Manage loading and error states using **AsyncValue**.

---

## 🛠️ Error Handling & Validation

- Handle errors in views using **SelectableText.rich** with red color for visibility.
- Manage empty states within the respective screens.
- Properly handle Supabase and network errors.

---

## 🎨 UI, Style & Design

- Use **LayoutBuilder** or **MediaQuery** for responsive layouts.
- Build **small, reusable widget classes**.
- Apply consistent themes with `Theme.of(context).textTheme`.
- Replace deprecated text styles like `headline6` with `titleLarge`.
- Use **RefreshIndicator** for pull-to-refresh.
- Set appropriate `textCapitalization`, `keyboardType`, and `textInputAction` in `TextFields`.
- Always implement an `errorBuilder` in `Image.network`.

---

## 🗂️ Models & Database Conventions

- Include `createdAt`, `updatedAt`, and `isDeleted` fields in database tables.
- Use `@JsonSerializable(fieldRename: FieldRename.snake)` for models.
- Apply `@JsonKey(includeFromJson: true, includeToJson: false)` for read-only fields.
- Use `@JsonValue(int)` for enums that persist in the database.

---

## 🧪 Testing

- Follow the **Arrange-Act-Assert** pattern for unit tests.
- Write unit tests for every public function.
- Use test doubles (fakes, mocks, stubs) for dependencies.
- Follow **Given-When-Then** for acceptance tests.

---

## ⚙️ Code Generation

- Use `build_runner` for generating code (Freezed, Riverpod, Hooks, JSON serialization).
- Standard command:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
