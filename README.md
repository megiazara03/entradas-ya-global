# 🎟️ EntradasYa — Monorepo / Repositorio Principal

Plataforma de venta y validación de entradas para eventos basada en una arquitectura de **microservicios políglotas**.

Este repositorio agrupa los 8 microservicios del proyecto para que cualquier miembro del equipo pueda clonar, configurar y ejecutar el sistema completo en su propio entorno **(local en Windows / Linux o en su propia máquina virtual / nube)** de forma totalmente independiente, sin requerir credenciales ni cuentas externas.

---

## 🏗️ Arquitectura del Sistema

El sistema está compuesto por 8 servicios independientes comunicados mediante **HTTP / REST + JSON**:

| Servicio | Lenguaje / Framework | Puerto | Base de Datos | Tipo | Rol / Función |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **[web](web/)** | React + Vite + Tailwind | `5173` / `80` | — | Público | Frontend web (clientes, organizadores y personal de acceso). |
| **[auth](auth/)** | Node.js (Express) | `3001` | `auth_db` | Público | Autenticación, registro, login y generación de tokens JWT. |
| **[events](events/)** | Python (FastAPI) | `3002` | `events_db` | Público | Gestión de eventos, sectores, precios y cupos disponibles. |
| **[tickets](tickets/)** | Python (FastAPI) | `3004` | `tickets_db` | Público | Generación de tickets en PDF con código QR y validación. |
| **[orders](orders/)** | .NET 8 (C# Web API) | `3006` | `orders_db` | Público | Orquesta compras de entradas y coordina pagos, tickets y notificaciones. |
| **[checkin](checkin/)** | Go (Golang) | `3007` | `checkin_db` | Público | Validación de entradas y control de acceso en la puerta del evento. |
| **[payments](payments/)** | Go (Golang) | `3003` | `payments_db` | **Interno** | Procesador simulado de transacciones de pago. |
| **[notifications](notifications/)** | Node.js (Express) | `3005` | — | **Interno** | Envío de correos transaccionales a servidor SMTP (Mailpit). |

### Diagrama de Enrutamiento y Nginx

```text
Navegador / Cliente
        │
        ▼ (Puerto 80)
   ┌─────────┐
   │  Nginx  │─── /              ──► Frontend React (archivos compilados)
   └────┬────┘─── /api/auth/     ──► auth (Node.js :3001)
        ├─── /api/events/   ──► events (FastAPI :3002)
        ├─── /api/tickets/  ──► tickets (FastAPI :3004)
        ├─── /api/orders/   ──► orders (.NET 8 :3006) ──► payments, tickets, notifications
        ├─── /api/checkin/  ──► checkin (Go :3007)     ──► tickets
        └─── /mailpit/      ──► Mailpit (Dashboard de correos :8025)

* Nota: payments (3003) y notifications (3005) son servicios internos. Solo responden a llamadas internas con el header `X-Internal-Token`.
```

---

## 🚀 Opción A: Ejecución en Servidor Propio (Ubuntu Server / Debian / VM)

Si cualquier miembro del grupo quiere levantar el entorno en una **Máquina Virtual (VirtualBox / VMware)** o en su **propia instancia en la nube (AWS / GCP / DigitalOcean)**:

### 1. Requisitos previos en el servidor
Instalar las dependencias base en Ubuntu:
```bash
sudo apt update && sudo apt install -y git curl unzip postgresql nginx
# Instalar Node.js 20+, Python 3.12+, Go 1.22+, .NET 8 Runtime / SDK y Mailpit
```

### 2. Clonar el repositorio
```bash
git clone https://github.com/megiazara03/entradas-ya-global.git
cd entradas-ya-global
```

### 3. Configuración automática de Bases de Datos y `.env`
El script `deploy/configurar-bd-y-env.sh` crea automáticamente todas las bases de datos de PostgreSQL, usuarios con permisos seguros y genera todos los archivos `.env` con secretos únicos:
```bash
# Reemplazar con la IP de tu servidor o 'localhost'
bash deploy/configurar-bd-y-env.sh <IP_DEL_SERVIDOR_O_LOCALHOST>
```

### 4. Instalar servicios systemd y Nginx
```bash
bash deploy/instalar-servicios.sh
```

### 5. Compilar y desplegar
```bash
bash deploy/desplegar.sh
```
¡Listo! La aplicación estará disponible en `http://<IP_DEL_SERVIDOR>/`.

---

## 💻 Opción B: Ejecución en Entorno Local (Windows)

Para desarrollar o probar sin montar servidores:

### 1. Requisitos
- **PostgreSQL 14+** corriendo localmente en el puerto `5432`.
- **Node.js 20+** y `npm`.
- **Python 3.11+** o **3.12**.
- **Go 1.22+**.
- **.NET 8 SDK**.
- **Mailpit** (para pruebas de correo).

### 2. Inicializar Bases de Datos
Ejecutar los scripts SQL incluidos en la carpeta `db/init.sql` de cada microservicio en tu PostgreSQL:
- `auth/db/init.sql`
- `events/db/init.sql`
- `orders/db/init.sql`
- `payments/db/init.sql`
- `tickets/db/init.sql`
- `checkin/db/init.sql`

### 3. Variables de Entorno
Copia cada `.env.example` como `.env` dentro de cada carpeta de servicio y coloca las credenciales de tu PostgreSQL local.

### 4. Iniciar todos los servicios
Puedes utilizar el script de PowerShell incluido:
```powershell
.\iniciar-local.ps1
```
O bien levantar cada microservicio en una terminal individual:
- **web:** `cd web && npm install && npm run dev` (Disponible en `http://localhost:5173`)
- **auth:** `cd auth && npm install && npm start`
- **events:** `cd events && pip install -r requirements.txt && uvicorn app.main:app --port 3002`
- **orders:** `cd orders && dotnet run`
- **tickets:** `cd tickets && pip install -r requirements.txt && uvicorn app.main:app --port 3004`
- **payments:** `cd payments && go run main.go`
- **checkin:** `cd checkin && go run main.go`
- **notifications:** `cd notifications && npm install && npm start`

---

## 🔄 Repositorios Individuales y Pipelines de CI/CD

Si necesitas consultar o trabajar sobre el pipeline independiente de cada microservicio, cada uno cuenta con su repositorio dedicado y su workflow en GitHub Actions:

- 🌐 [web](https://github.com/megiazara03/web)
- 🔐 [auth](https://github.com/megiazara03/auth)
- 🎪 [events](https://github.com/megiazara03/events)
- 📦 [orders](https://github.com/megiazara03/orders)
- 💳 [payments](https://github.com/megiazara03/payments)
- 🎟️ [tickets](https://github.com/megiazara03/tickets)
- 🔍 [checkin](https://github.com/megiazara03/checkin)
- 📧 [notifications](https://github.com/megiazara03/notifications)

Cada repositorio individual tiene configurado su pipeline en `.github/workflows/pipeline.yml` para desplegar automáticamente al hacer `push` en la rama `develop`.
