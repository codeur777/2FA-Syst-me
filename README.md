# 2FA Systeme

Système d'authentification à deux facteurs (2FA) — monorepo complet avec backend, frontend web et application mobile.

## Structure du projet

```
.
├── BACKEND/
│   └── 2fasysteme/          # API REST — Spring Boot (Java 21, Maven)
├── FRONTEND_WEB/
│   └── 2fasysteme/          # Interface web — React 19 + Vite
└── FRONTEND_MOBILE/
    └── twofasysteme/        # Application mobile — Flutter (Dart)
```

## Stack technique

| Couche          | Technologie                        |
|-----------------|------------------------------------|
| Backend         | Java 21, Spring Boot 4, Maven      |
| Sécurité        | Spring Security                    |
| Frontend Web    | React 19, Vite 7, ESLint           |
| Mobile          | Flutter 3, Dart SDK ^3.10          |

---

## Prérequis

- Java 21+
- Maven 3.9+
- Node.js 20+ & npm
- Flutter SDK 3.10+

---

## Lancer le projet

### Backend (Spring Boot)

```bash
cd BACKEND/2fasysteme
./mvnw spring-boot:run
```

L'API démarre sur `http://localhost:8080`.

### Frontend Web (React + Vite)

```bash
cd FRONTEND_WEB/2fasysteme
npm install
npm run dev
```

L'interface est accessible sur `http://localhost:5173`.

### Frontend Mobile (Flutter)

```bash
cd FRONTEND_MOBILE/twofasysteme
flutter pub get
flutter run
```

---

## Variables d'environnement

Créer un fichier `.env` à la racine de chaque module (ne jamais committer ces fichiers) :

**Backend** — `BACKEND/2fasysteme/src/main/resources/application-local.properties`
```properties
# Exemple
spring.datasource.url=jdbc:postgresql://localhost:5432/twofadb
spring.datasource.username=your_user
spring.datasource.password=your_password
```

**Frontend Web** — `FRONTEND_WEB/2fasysteme/.env.local`
```env
VITE_API_URL=http://localhost:8080
```

---

## Build production

```bash
# Backend
cd BACKEND/2fasysteme && ./mvnw clean package

# Frontend Web
cd FRONTEND_WEB/2fasysteme && npm run build

# Mobile (Android)
cd FRONTEND_MOBILE/twofasysteme && flutter build apk --release
```

---

## Licence

Voir le fichier [LICENSE](./LICENSE).
