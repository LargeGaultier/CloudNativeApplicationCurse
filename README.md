# Gym Management System

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=SabSab93_CloudNativeApplicationCurse&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=SabSab93_CloudNativeApplicationCurse)

A complete fullstack gym management application built with modern web technologies.

## Features

### User Features
- **User Dashboard**: View stats, billing, and recent bookings
- **Class Booking**: Book and cancel fitness classes
- **Subscription Management**: View subscription details and billing
- **Profile Management**: Update personal information

### Admin Features
- **Admin Dashboard**: Overview of gym statistics and revenue
- **User Management**: CRUD operations for users
- **Class Management**: Create, update, and delete fitness classes
- **Booking Management**: View and manage all bookings
- **Subscription Management**: Manage user subscriptions

### Business Logic
- **Capacity Management**: Classes have maximum capacity limits
- **Time Conflict Prevention**: Users cannot book overlapping classes
- **Cancellation Policy**: 2-hour cancellation policy (late cancellations become no-shows)
- **Billing System**: Dynamic pricing with no-show penalties
- **Subscription Types**: Standard (€30), Premium (€50), Student (€20)

## Tech Stack

### Backend
- **Node.js** with Express.js
- **Prisma** ORM with PostgreSQL
- **RESTful API** with proper error handling
- **MVC Architecture** with repositories pattern

### Frontend
- **Vue.js 3** with Composition API
- **Pinia** for state management
- **Vue Router** with navigation guards
- **Responsive CSS** styling

### DevOps
- **Docker** containerization
- **Docker Compose** for orchestration
- **PostgreSQL** database
- **Nginx** for frontend serving

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gym-management-system
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file if needed (default values should work for development).

3. **Start the application**
   ```bash
   docker-compose up --build
   ```

4. **Access the application**
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:3000
   - Database: localhost:5432

### Default Login Credentials

The application comes with seeded test data:

**Admin User:**
- Email: admin@gym.com
- Password: admin123
- Role: ADMIN

**Regular Users:**
- Email: john.doe@email.com
- Email: jane.smith@email.com  
- Email: mike.wilson@email.com
- Password: password123 (for all users)

## Project Structure

```
gym-management-system/
├── backend/
│   ├── src/
│   │   ├── controllers/     # Request handlers
│   │   ├── services/        # Business logic
│   │   ├── repositories/    # Data access layer
│   │   ├── routes/          # API routes
│   │   └── prisma/          # Database schema and client
│   ├── seed/                # Database seeding
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── views/           # Vue components/pages
│   │   ├── services/        # API communication
│   │   ├── store/           # Pinia stores
│   │   └── router/          # Vue router
│   ├── Dockerfile
│   └── nginx.conf
└── docker-compose.yml
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Classes
- `GET /api/classes` - Get all classes
- `GET /api/classes/:id` - Get class by ID
- `POST /api/classes` - Create class
- `PUT /api/classes/:id` - Update class
- `DELETE /api/classes/:id` - Delete class

### Bookings
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/user/:userId` - Get user bookings
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id/cancel` - Cancel booking
- `DELETE /api/bookings/:id` - Delete booking

### Subscriptions
- `GET /api/subscriptions` - Get all subscriptions
- `GET /api/subscriptions/user/:userId` - Get user subscription
- `POST /api/subscriptions` - Create subscription
- `PUT /api/subscriptions/:id` - Update subscription

### Dashboard
- `GET /api/dashboard/user/:userId` - Get user dashboard
- `GET /api/dashboard/admin` - Get admin dashboard

## Development

### Local Development Setup

1. **Backend Development**
   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. **Frontend Development**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. **Database Setup**
   ```bash
   cd backend
   npx prisma migrate dev
   npm run seed
   ```

### Database Management

- **View Database**: `npx prisma studio`
- **Reset Database**: `npx prisma db reset`
- **Generate Client**: `npx prisma generate`
- **Run Migrations**: `npx prisma migrate deploy`

### Useful Commands

```bash
# Stop all containers
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Rebuild specific service
docker-compose up --build [service-name]

# Access database
docker exec -it gym_db psql -U postgres -d gym_management
```

## Features in Detail

### Subscription System
- **STANDARD**: €30/month, €5 per no-show
- **PREMIUM**: €50/month, €3 per no-show  
- **ETUDIANT**: €20/month, €7 per no-show

### Booking Rules
- Users can only book future classes
- Maximum capacity per class is enforced
- No double-booking at the same time slot
- 2-hour cancellation policy

### Admin Dashboard
- Total users and active subscriptions
- Booking statistics (confirmed, no-show, cancelled)
- Monthly revenue calculations
- User management tools

### User Dashboard
- Personal statistics and activity
- Current subscription details
- Monthly billing with no-show penalties
- Recent booking history

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.


## Development Workflow & Code Quality

This project follows a **Git workflow** designed to ensure code quality, consistency, and scalability in a collaborative environment.

### Git Branching Strategy

- **main**: production-ready code  
- **develop**: integration branch  
- **feature/<name>**: feature-specific branches  

All changes are merged into `develop` via Pull Requests.  
Direct pushes to `main` and `develop` are restricted through branch protection rules.

![branch main](/asset/img/main.png)

![branch develop](/asset/img/develop.png)

![rules](/asset/img/rules.png)
### Commit Quality Enforcement

The project enforces the **Conventional Commits** specification using **Commitlint**.

**Commit format:**
```
<type>: <description>
```

**Allowed types:**
- feat
- fix
- chore
- docs
- refactor
- test

Example:
```
chore: setup husky and commitlint
```


### Automated Git Hooks with Husky

Husky is used to run automated checks before commits are created.

**Pre-commit hook**
```
npm run lint:all
```

Scripts executed at the repository root:
```
lint:front → cd frontend && npm run lint
lint:back  → cd backend && npm run lint
lint:all   → npm run lint:front && npm run lint:back
```

This ensures consistent code quality across frontend and backend.

### CI/CD Readiness

The current workflow prepares the project for future automation:
- GitHub Actions integration
- Automated linting and testing
- Container-based deployment pipelines
- Scalable DevOps practices


### Summary

This workflow provides:
- Clean and consistent commit history
- Enforced quality standards
- Safe collaboration practices
- A production-ready foundation for CI/CD


## 🚀 CI Pipeline Overview

This project includes a complete **Continuous Integration (CI)** pipeline executed via **GitHub Actions** on a **self-hosted runner**.

### Pipeline stages:

```
Pull Request / Push
        ↓
      Lint
        ↓
      Build
        ↓
      Tests
        ↓
   SonarCloud Scan
        ↓
   Quality Gate
        ↓
   Merge allowed
```

- **Lint**: Frontend & backend code quality checks
- **Build**: Application build validation
- **Tests**: Backend automated tests
- **SonarCloud**: Static analysis and technical debt detection
- **Quality Gate**: Blocks merge if quality requirements are not met

---

## 🔐 Git Workflow Rules (TP1 + TP2)

This repository follows strict Git and DevOps rules to ensure quality and stability.

### Branch strategy

- **main**: Production-ready code (protected)
- **develop**: Integration branch (protected)
- **feature/***: Feature development branches

### Mandatory rules

- No direct push on `main` or `develop`
- All changes go through **Pull Requests**
- CI pipeline **must pass** before merge
- **SonarCloud Quality Gate must pass**

### Commit conventions

The project enforces **Conventional Commits** via **Commitlint**:

```
<type>: <short description>
```

Allowed types:
- feat
- fix
- chore
- docs
- refactor
- test

Example:
```
chore: setup husky and commitlint
```

### Husky Git Hooks

Husky runs automated checks before each commit:

```
npm run lint:all
```

Which executes:
- Frontend lint
- Backend lint

---

## Features

### User Features
- **User Dashboard**: View stats, billing, and recent bookings
- **Class Booking**: Book and cancel fitness classes
- **Subscription Management**: View subscription details and billing
- **Profile Management**: Update personal information

### Admin Features
- **Admin Dashboard**: Overview of gym statistics and revenue
- **User Management**: CRUD operations for users
- **Class Management**: Create, update, and delete fitness classes
- **Booking Management**: View and manage all bookings
- **Subscription Management**: Manage user subscriptions

### Business Logic
- **Capacity Management**: Classes have maximum capacity limits
- **Time Conflict Prevention**: Users cannot book overlapping classes
- **Cancellation Policy**: 2-hour cancellation policy
- **Billing System**: Dynamic pricing with penalties
- **Subscription Types**: Standard (€30), Premium (€50), Student (€20)

---

## Tech Stack

### Backend
- Node.js (Express)
- Prisma ORM + PostgreSQL
- REST API

### Frontend
- Vue.js 3
- Pinia
- Vue Router

### DevOps
- Docker & Docker Compose
- GitHub Actions CI
- SonarCloud


## 🚀 Docker & Docker Compose

This project is fully containerized and can be started with **a single command** using Docker Compose.

### ✔ How to start the environment

```bash
docker compose up --build
```

To stop and clean everything:

```bash
docker compose down -v
```

### ✔ Accessible URLs

- **Frontend**: http://localhost:8080  
- **Backend**: http://localhost:3000  
- **PostgreSQL**: local access only (via Docker network)

### ✔ Docker Images (GHCR)

- **Backend**: `ghcr.io/<username>/cloudnative-backend:latest`
- **Frontend**: `ghcr.io/<username>/cloudnative-frontend:latest`

> Images are built and pushed automatically by the CI pipeline.

### ✔ CI Pipeline Execution Conditions

- Requires a **self-hosted GitHub Actions runner**
- Required secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_PASSWORD`
  - `SONAR_TOKEN`

### ✔ CI Status Badge

![CI](https://github.com/<username>/<repository>/actions/workflows/ci.yml/badge.svg)

---

## Features

### User Features
- **User Dashboard**: View stats, billing, and recent bookings
- **Class Booking**: Book and cancel fitness classes
- **Subscription Management**: View subscription details and billing
- **Profile Management**: Update personal information

### Admin Features
- **Admin Dashboard**: Overview of gym statistics and revenue
- **User Management**: CRUD operations for users
- **Class Management**: Create, update, and delete fitness classes
- **Booking Management**: View and manage all bookings
- **Subscription Management**: Manage user subscriptions

### Business Logic
- **Capacity Management**
- **Time Conflict Prevention**
- **2-hour Cancellation Policy**
- **Dynamic Billing System**
- **Subscription Types**: Standard (€30), Premium (€50), Student (€20)

---

## Tech Stack

### Backend
- Node.js with Express
- Prisma ORM + PostgreSQL
- RESTful API

### Frontend
- Vue.js 3
- Pinia
- Vue Router

### DevOps
- Docker
- Docker Compose
- GitHub Actions
- SonarCloud
- Nginx

---

## Development Workflow & Code Quality

- **main**: production branch
- **develop**: integration branch
- **feature/***: feature branches

All changes go through Pull Requests with mandatory CI checks.

### Commit Convention

```
<type>: <description>
```

Allowed types:
- feat
- fix
- chore
- docs
- refactor
- test

---

## CI Pipeline Overview

```
Pull Request / Push
        ↓
      Lint
        ↓
      Build
        ↓
      Tests
        ↓
   SonarCloud Scan
        ↓
   Quality Gate
        ↓
   Docker Build & Push
```

---

## Summary

This project delivers:
- One-command Docker startup
- Full CI/CD-ready architecture
- Strong code quality enforcement
- Production-grade DevOps setup


## 🚀 Docker & Docker Compose (TP3)

This project is fully containerized and can be started with **a single command** using Docker Compose.

### ✔ How to start the environment via Docker Compose

```bash
docker compose up --build
```

(Optional) Stop and remove volumes:

```bash
docker compose down -v
```

### ✔ Accessible URLs

- **Frontend**: http://localhost:8080  
- **Backend**: http://localhost:3000  
- **Postgres**: local only (internal Docker network)

### ✔ Docker images (GHCR)

- **Backend**: `ghcr.io/<username>/cloudnative-backend:latest`  
- **Frontend**: `ghcr.io/<username>/cloudnative-frontend:latest`

### ✔ CI pipeline execution conditions

- Requires a **self-hosted runner**
- Required secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_PASSWORD`
  - `SONAR_TOKEN`

### ✔ CI Badge

![CI](https://github.com/<username>/<repository>/actions/workflows/ci.yml/badge.svg)

(Optional) Docker pulls badge can be added later if required.

### Summary

Dockerization (frontend + backend + postgres) allows the full stack to be started consistently with a single command (`docker compose up --build`).  
Images are built and pushed automatically by the CI pipeline.

## 🔄 Automated Local Deployment

This project includes an **automated local deployment stage** as part of its CI pipeline, executed through **GitHub Actions** on a **self-hosted runner**.

The goal is to ensure that once valid Docker images are built and published, the application is **automatically restarted locally**, without manual intervention and **without losing PostgreSQL data**.

---

### How the deploy stage works

The `deploy` job is triggered **automatically after a valid Docker image is published to the remote registry (GHCR)**.

It executes the following steps:

1. Stops the currently running Docker Compose stack **without removing volumes**
2. Pulls the latest Docker images from **GHCR**, tagged with the current commit SHA
3. Recreates the backend environment file required by Docker Compose
4. Restarts the full application using Docker Compose

All deployment logic is stored in a dedicated script:

```bash
scripts/deploy.sh
```

This ensures the deployment process is **clear, reproducible, and idempotent**.

---

### Deployment workflow overview

The deployment stage is executed only after the Docker images have been successfully pushed.

```
lint → build → tests → docker build → push registry → deploy
```

---

### Requirements

To run the automated deployment, the following conditions must be met:

- A **self-hosted GitHub Actions runner** running on the target machine
- Docker and Docker Compose installed on the runner host
- Access to a remote Docker registry (GitHub Container Registry)
- The following GitHub secrets configured:
  - POSTGRES_USER
  - POSTGRES_PASSWORD
  - POSTGRES_DB
  - DATABASE_URL
  - SONAR_TOKEN

---

### Active deployment branches

For this coursework:

- **Automated deployment is enabled only on the `develop` branch**
- Pull Requests or pushes targeting other branches do not trigger the deploy stage

---

### Idempotency guarantees

The deployment is designed to be **idempotent** and can be executed multiple times in a row:

- No use of `docker compose down --volumes`
- PostgreSQL volumes are preserved
- Docker images are always pulled from the remote registry
- Containers are cleanly restarted on each deployment

