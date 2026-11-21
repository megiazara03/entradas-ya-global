# 🎟️ EntradasYa — Repositorio Global & Guía de Despliegue CI/CD

Plataforma de venta y validación de entradas para eventos basada en una arquitectura de **microservicios políglotas**.

Este repositorio agrupa los 8 microservicios del proyecto y detalla:
1. **Cómo funciona la arquitectura en producción (AWS EC2 + GitHub Actions CI/CD)**.
2. **Cómo replicar los 8 pipelines de CI/CD en cualquier cuenta propia de AWS o servidor Linux**.
3. **Cómo ejecutar el sistema completo en modo local o en máquina virtual sin depender de AWS**.

---

## 🏗️ Arquitectura del Sistema

El sistema está compuesto por 8 servicios independientes comunicados mediante **HTTP / REST + JSON**:

| Servicio | Lenguaje / Framework | Puerto | Base de Datos | Tipo | Rol / Función | Repositorio GitHub |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **web** | React + Vite | `80` (prod) / `5173` | — | Público | Frontend web (clientes, organizadores y porteros) | [megiazara03/web](https://github.com/megiazara03/web) |
| **auth** | Node.js (Express) | `3001` | `auth_db` | Público | Autenticación, registro, login y tokens JWT | [megiazara03/auth](https://github.com/megiazara03/auth) |
| **events** | Python (FastAPI) | `3002` | `events_db` | Público | Catálogo de eventos, sectores, precios y aforos | [megiazara03/events](https://github.com/megiazara03/events) |
| **tickets** | Python (FastAPI) | `3004` | `tickets_db` | Público | Emisión de entradas en PDF con QR y validación | [megiazara03/tickets](https://github.com/megiazara03/tickets) |
| **orders** | .NET 8 (C#) | `3006` | `orders_db` | Público | Orquestación de compras (coordina pagos, tickets y avisos) | [megiazara03/orders](https://github.com/megiazara03/orders) |
| **checkin** | Go (Golang) | `3007` | `checkin_db` | Público | Control de acceso y validación en la puerta del evento | [megiazara03/checkin](https://github.com/megiazara03/checkin) |
| **payments** | Go (Golang) | `3003` | `payments_db` | **Interno** | Procesamiento simulado de pagos | [megiazara03/payments](https://github.com/megiazara03/payments) |
| **notifications** | Node.js (Express) | `3005` | — | **Interno** | Envío de correos transaccionales a Mailpit | [megiazara03/notifications](https://github.com/megiazara03/notifications) |

---

## ☁️ Arquitectura de Despliegue en AWS EC2

Actualmente la versión en producción corre sobre una instancia de **AWS EC2**:
* **Sistema Operativo:** Ubuntu 24.04 LTS (x86_64 / amd64).
* **Reverse Proxy:** **Nginx** escucha en el puerto `80` y enruta el tráfico hacia el frontend y las APIs correspondientes.
* **Seguridad (Security Group de AWS):**
  - Puerto `22` (SSH) abierto para despliegue y administración.
  - Puerto `80` (HTTP) abierto a `0.0.0.0/0` para acceso público web.

```text
Usuario / Navegador
        │
        ▼ (Puerto 80 HTTP)
┌─────────────────────────────────── AWS EC2 (Ubuntu) ───────────────────────────────────┐
│                                                                                        │
│                                      ┌───────────┐                                     │
│                                      │   Nginx   │                                     │
│                                      └─────┬─────┘                                     │
│            ┌───────────────────────────────┼───────────────────────────────┐           │
│            │ /                             │ /api/{servicio}/              │ /mailpit/ │
│            ▼                               ▼                               ▼           │
│   Frontend React              Microservicios Locales                    Mailpit        │
│   (/var/www/entradasya)       ├── auth          (:3001)                (Puerto 8025)   │
│                               ├── events        (:3002)                                │
│                               ├── tickets       (:3004)                                │
│                               ├── orders        (:3006) ──► payments (:3003)           │
│                               └── checkin       (:3007) ──► notifications (:3005)      │
│                                                                                        │
│   Gestor de Procesos: systemd (entradasya-auth, entradasya-events, etc.)               │
│   Base de Datos: PostgreSQL (auth_db, events_db, tickets_db, etc.)                    │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Cómo Replicar los 8 Repositorios con Despliegue CI/CD en tu Propia Cuenta

Si un compañero de equipo quiere clonar o hacer fork de los 8 repositorios y tener su propio pipeline de CI/CD desplegando en su propio servidor EC2 (o cualquier Linux):

### Paso 1: Crear y Configurar la Instancia EC2 en AWS
1. Lanzar una instancia EC2 con **Ubuntu Server 24.04 LTS**.
2. Descargar la clave privada SSH (archivo `.pem`).
3. En el **Security Group**, habilitar inbound rules:
   - **SSH (22):** `0.0.0.0/0` (o restringido a tu IP).
   - **HTTP (80):** `0.0.0.0/0`.
4. Conectarse a la máquina por SSH y aprovisionar el entorno (o correr los scripts de `deploy/` incluidos en este repositorio):
   - Instalar: `postgresql`, `nginx`, `nodejs 20+`, `python3-venv`, `golang-go`, `dotnet-runtime-8.0`, `mailpit`.

### Paso 2: Configurar los GitHub Secrets en CADA UNO de los 8 Repositorios
Cada uno de los 8 repositorios contiene un archivo de workflow en `.github/workflows/pipeline.yml` que se dispara automáticamente con cada `git push` a la rama `develop`.

Para que el pipeline de GitHub Actions sepa dónde y cómo desplegar, ve a:
👉 **Repositorio en GitHub** ➔ **Settings** ➔ **Secrets and variables** ➔ **Actions** ➔ **New repository secret**

Debes configurar estos **3 Secrets obligatorios en los 8 repositorios**:

| Nombre del Secret | Descripción | Ejemplo de Valor |
| :--- | :--- | :--- |
| `EC2_HOST` | La dirección IP pública o DNS público de tu servidor EC2 | `52.73.204.67` |
| `EC2_USER` | El usuario de login SSH de tu servidor | `ubuntu` |
| `EC2_SSH_KEY` | El contenido completo del archivo de clave privada `.pem` | `-----BEGIN RSA PRIVATE KEY----- ... -----END RSA PRIVATE KEY-----` |

> ⚠️ **Importante al pegar `EC2_SSH_KEY`:** Abre el archivo `.pem` con un editor de texto (Notepad / VS Code) y copia todo el texto íntegro, incluyendo las líneas `-----BEGIN ...-----` y `-----END ...-----`.

### Paso 3: ¿Qué hace el Pipeline de GitHub Actions en cada Push?
Al hacer `git push origin develop` en cualquiera de los repositorios:
1. **Runner de GitHub:** Clona el código, instala dependencias y ejecuta las pruebas / build del microservicio.
2. **Generación de Artifact:** Empaqueta los binarios o código compilado en un archivo comprimido `.tar.gz`.
3. **Despliegue SSH/SCP:** Se conecta a la EC2 usando los 3 secretos configurados (`EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`).
4. **Instalación y Reinicio:** Descomprime el artefacto en `/home/ubuntu/entradas-ya/<servicio>` (o en `/var/www/entradasya` para el frontend) y reinicia el servicio en systemd (`sudo systemctl restart entradasya-<servicio>`).

---

## 💻 Opción Local / Offline (Sin AWS ni Cuentas Externas)

Si no cuentas con cuenta de AWS y solo quieres ejecutar y probar el proyecto completo en tu computadora personal:

### 1. Clonar el repositorio con todos sus microservicios
```bash
git clone --recurse-submodules https://github.com/megiazara03/entradas-ya-global.git
cd entradas-ya-global
```

### 2. Prerrequisitos en Windows / Linux
* **PostgreSQL** en ejecución en el puerto `5432`.
* **Node.js 20+** y `npm`.
* **Python 3.11+ / 3.12+**.
* **Go 1.22+**.
* **.NET 8 SDK**.
* **Mailpit** (descargar ejecutable para ver correos en `http://localhost:8025`).

### 3. Crear Bases de Datos
Ejecuta los scripts SQL iniciales ubicados en cada microservicio:
```bash
psql -U postgres -f auth/db/init.sql
psql -U postgres -f events/db/init.sql
psql -U postgres -f orders/db/init.sql
psql -U postgres -f payments/db/init.sql
psql -U postgres -f tickets/db/init.sql
psql -U postgres -f checkin/db/init.sql
```

### 4. Variables de Entorno
Copia cada `.env.example` como `.env` dentro de cada carpeta y ajusta la contraseña de tu PostgreSQL local.

### 5. Iniciar todo con un solo comando (PowerShell)
```powershell
.\iniciar-local.ps1
```
El frontend abrirá en **`http://localhost:5173`** y el dashboard de correos en **`http://localhost:8025`**.
