Claro, aquí tienes una versión completa del README en **inglés**, adaptada de tu proyecto y manteniendo el estilo bonito y profesional:

```markdown
# Parking App - Flutter

Welcome to the **Parking** app, a Flutter project designed to manage vehicles, users, and subscribers, with features like registration, editing, filtering, and PDF report generation.

---

## 📂 Project Structure

The project is organized as follows:

```

android/           # Android files and configuration
ios/               # iOS files and configuration
lib/
├─ editar/        # Edit pages
│   ├─ editar_carro.dart
│   ├─ editar_categoria.dart
│   ├─ editar_marca.dart
│   └─ editar_pensionado.dart
├─ icons/         # Icons used in the app
│   ├─ car.png
│   ├─ categoria.png
│   ├─ marca.png
│   ├─ pensionados.png
│   └─ usuario.png
├─ images/        # Images used in the app
└─ registros/     # Registration pages
├─ registrar_carro.dart
├─ registrar_categoria.dart
├─ registrar_marca.dart
├─ registrar_pensionado.dart
└─ registrar_usuario.dart

```

---

## 📝 Main Features

1. **Data Registration**
   - Register **users**, **vehicles**, **brands**, **categories**, and **subscribers**.
   - Validated and standardized date formats.

2. **Editing Records**
   - Modify existing information.
   - Automatic adjustment of end date when the start date changes for subscribers.

3. **Filtering and Search**
   - Search records by **phone number**.
   - Dynamic filtering for subscribers, vehicles, and users.

4. **Visual Indicators**
   - Icons showing subscription status based on the end date.
   - Colors: red (expired), yellow (expiring soon), green (active).

5. **Reports**
   - Generate **PDF reports** for subscribers and other records.

6. **Supabase Integration**
   - Full CRUD operations on Supabase tables.
   - Conversion between `Map<String, dynamic>` and Dart objects.

---

## 📅 Dates and Formats

- Dates are displayed in **dd-MM-yyyy** format for clarity.
- **End date** automatically adjusts if the **start date** changes.

---

## 💡 What We Learned

- Using **ValueNotifier** to dynamically update the UI.
- Mapping and converting Supabase data to Dart objects.
- Using **TextEditingController**, **DropdownButtonFormField**, and **DatePicker**.
- Dynamic list filtering and search functionality.
- Creating **PDF reports** from Flutter.
- Organizing folders and modularizing code for maintainability.

---

## 🚀 Next Steps

- Add user authentication.
- Implement more custom reports.
- Enhance user experience with advanced validations.

---

## 🖤 Thanks for checking out this project
```

