¡Perfecto! Te hago un **README avanzado, visual y completo**, incluyendo **toda la información que hemos trabajado juntos**: Flutter, Supabase, manejo de fechas, filtros, reportes, edición, eliminación, etc. Le agrego **badges, emojis y secciones plegables** para que se vea profesional en GitHub.

---

# 🚗 Pensionados App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=flat&logo=supabase&logoColor=white)](https://supabase.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)

A **Flutter application** integrated with **Supabase** to manage **long-term parking clients (pensionados)**.
This app allows you to **register, view, edit, delete, filter, and generate reports** with real-time updates.

---

## ✨ Features

<details>
<summary>Click to expand 🚀</summary>

- **CRUD Operations**

  - Create, read, update, delete pensionados.

- **Dynamic Dropdowns**

  - Brands and categories loaded dynamically from Supabase.

- **Real-time Search & Filters**

  - Filter pensionados by phone number.

- **Automatic Date Handling**

  - Start date (`fechaInicio`) and end date (`fechaFin`) managed automatically.
  - End date updates automatically when start date changes.
  - Dates displayed in `dd-MM-yyyy` format.

- **UI Indicators for Subscription Status**

  - 🟢 Green: Active
  - 🟡 Yellow: Expiring soon
  - 🔴 Red: Expired

- **Dialogs & User Interaction**

  - View details, edit pensionados, confirm deletion.

- **PDF Report Generation**

  - Export filtered pensionados to PDF reports.

- **State Management**

  - `setState` and `ValueNotifier` used for reactive UI updates.

</details>

---

## 🛠 Technologies Used

- **Flutter & Dart**
- **Supabase** (Database, Auth)
- **intl** (Date formatting)
- PDF generation via custom mapping
- `ValueNotifier` for reactive state on `fechaFin`

---

## 💡 Key Learnings

<details>
<summary>Click to expand 📚</summary>

- How to **map Supabase data** (`List<Map<String, dynamic>>`) into Dart models (`Pensionado`).
- Correct **handling of nullable dates** and conversion to readable formats.
- Automatic UI updates with `ValueNotifier`.
- Implementing **dependent fields**, like updating `fechaFin` based on `fechaInicio`.
- Building **dynamic dropdowns** from database tables (`marcas`, `categorias`).
- Filtering lists in Flutter with `where` and `toLowerCase()` for case-insensitive search.
- Using **dialogs** to display details and confirm actions.
- Writing **clean and reusable widgets** (`campoTexto`, `dropdownCampo`, `fechaCampo`).
- Generating PDF reports from **filtered data**.
- Using **commit messages** that reflect learning progress, e.g., `"9th update: automatic fechaFin update when fechaInicio changes"`.

</details>

---

## 🖥 UI Screenshots

- **Pensionados List** – colored subscription status icons
- **View Details Dialog** – formatted dates
- **Edit Pensionado** – auto-update end date when start date changes
- **PDF Report** – exported filtered list

_(Add your own screenshots in this section for visual appeal)_

---

## 🚀 Getting Started

1. **Clone the repository**

```bash
git clone <repository-url>
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

---

## 📝 Notes & Tips

- Ensure your Supabase tables exist with correct column names:

  - `Pensionados` → `id`, `Nombre`, `Apellido`, `Teléfono`, `Marca`, `Categoria`, `Placas`, `Pago_Men`, `Fecha_Inicio`, `Fecha_Fin`
  - `marcas` → `marcas`
  - `categorias` → `categoria`

- Dates should be stored in `yyyy-MM-dd` format to avoid timestamps like `T00:00:00.000`.
- `ValueNotifier` is essential for automatically updating **end date** indicators in the UI.
- Use **clear commit messages** to track your learning progress.

---

Si quieres, puedo hacer **una versión todavía más profesional con emojis en cada sección, badges de “Learning Progress”, y links a commits específicos**, para que quede como un README de portafolio.

¿Quieres que haga esa versión aún más “pro”?
