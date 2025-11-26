# Clean Architecture Structure

Dự án đã được cấu trúc lại theo Clean Architecture pattern.

## Cấu trúc thư mục

```
lib/
├── domain/              # Domain Layer - Business Logic
│   ├── entities/        # Domain entities (pure business objects)
│   ├── repositories/    # Repository interfaces (abstract classes)
│   └── usecases/        # Use cases (business logic)
│
├── data/                # Data Layer - Data Management
│   ├── models/          # Data models (DTOs)
│   ├── repositories/    # Repository implementations
│   ├── datasources/     # Data sources
│   │   ├── remote/      # Remote data sources (API services)
│   │   └── local/       # Local data sources (cache, database)
│   └── mappers/         # Mappers between entities and models
│
├── app/                 # Presentation Layer - UI
│   ├── providers/       # State management (Provider)
│   ├── pages/           # UI pages/screens
│   └── widgets/         # Reusable widgets
│
└── shared/              # Shared Layer - Common utilities
    ├── config/          # Configuration
    ├── theme/           # App theme
    ├── utils/           # Utilities
    └── constants/       # Constants
```

## Layers

### 1. Domain Layer (`domain/`)
- **Entities**: Pure business objects, không phụ thuộc vào framework
- **Repositories**: Interfaces định nghĩa contracts cho data access
- **Use Cases**: Business logic, orchestrate data flow

### 2. Data Layer (`data/`)
- **Models**: Data Transfer Objects (DTOs) từ API
- **Repositories**: Implementations của repository interfaces
- **Data Sources**: Remote (API) và Local (cache, database)
- **Mappers**: Chuyển đổi giữa entities và models

### 3. App Layer (`app/`)
- **Providers**: State management với Provider pattern
- **Pages**: UI screens/pages
- **Widgets**: Reusable UI components

### 4. Shared Layer (`shared/`)
- **Config**: App configuration (API endpoints, etc.)
- **Theme**: App theme và styling
- **Utils**: Utility functions
- **Constants**: App constants

## Dependency Flow

```
app → domain ← data
 ↓      ↑
shared  └── entities
```

- **app** phụ thuộc vào **domain** và **shared**
- **data** phụ thuộc vào **domain** và **shared**
- **domain** không phụ thuộc vào bất kỳ layer nào khác

## Migration Notes

- Models đã được di chuyển từ `lib/models/` → `lib/data/models/`
- Services đã được di chuyển từ `lib/services/` → `lib/data/datasources/remote/`
- Providers đã được di chuyển từ `lib/providers/` → `lib/app/providers/`
- Screens đã được di chuyển từ `lib/screens/` → `lib/app/pages/`
- Widgets đã được di chuyển từ `lib/widgets/` → `lib/app/widgets/`
- Config đã được di chuyển từ `lib/config/` → `lib/shared/config/`
- Theme đã được di chuyển từ `lib/theme/` → `lib/shared/theme/`

Tất cả imports đã được cập nhật để phản ánh cấu trúc mới.

## Next Steps

1. Tạo repository interfaces trong `domain/repositories/`
2. Tạo use cases trong `domain/usecases/`
3. Implement repositories trong `data/repositories/`
4. Refactor providers để sử dụng use cases thay vì gọi trực tiếp services
5. Thêm local data sources nếu cần (cache, database)

