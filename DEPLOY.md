# Deploying ID Manager with Docker

The same shape as the old ID Card Manager deployment: two images (`api`, `ui`) built on a dev machine
and pushed to GHCR, and a server that only needs `docker-compose.yml` and a `.env`.

| Service    | What it is                                  | Port on the server |
| ---------- | ------------------------------------------- | ------------------ |
| `postgres` | PostgreSQL 16, database **IDManager**       | 5433               |
| `api`      | the .NET 8 API (also runs the migrations)   | 5165               |
| `ui`       | the Flutter web app, served by nginx        | 5144               |

The UI forwards `/api/` to the API itself, so open the app at `http://<server>:5144` - nothing else
has to be configured for the browser to reach the API.

## A fresh database

This app has its **own** database: `IDManager`, in its own volume (`idmanager-postgres-data`). It does
not use the old app's database (`IDCardMaster`, volume `postgres-data`) or any development machine's
database, and nothing is copied over. On the first start the API:

1. creates every table (Entity Framework migrations run at startup), and
2. because the database has no users, creates one **Super Admin**:

   | Phone        | Password  |
   | ------------ | --------- |
   | `9943135008` | `Red@123` |

   (Set `SEED_ADMIN_PHONE` / `SEED_ADMIN_PASSWORD` in `.env` to use others.) This only happens on an
   empty database - it never touches an existing one. **Change the password after the first login.**

## One-time setup on the dev machine

```bash
docker login ghcr.io          # with a personal access token that has write:packages
```

## Build and push

```bash
./scripts/build-and-push.sh
```

Builds both images (`linux/amd64`), tags each `:latest` and with the current git short SHA, and pushes
all four tags. The images are `ghcr.io/retinuesoft/idcardmanager-api` and
`ghcr.io/retinuesoft/idcardmanager-ui` - the same names as the old app, so pushing **replaces the old
app's `:latest` in the registry**. Do it when you mean to switch over.

## On the server

```bash
# once: put docker-compose.yml on the server, then create .env from .env.example
cp .env.example .env      # set POSTGRES_PASSWORD and JWT_KEY (and IDCM_PUBLIC_HOST if you use a domain/IP)
docker login ghcr.io      # once, with a read:packages token (if the images are private)

docker compose pull
docker compose up -d
```

### Replacing the old app

The old and the new stacks use the same ports (5433, 5165, 5144) and service names, so **stop the old
one first**, in the old app's folder:

```bash
docker compose down        # without -v: keeps the old database volume (postgres-data), untouched
```

Then start this one as above. The old data stays in `postgres-data` (nothing reads it any more); remove
it later with `docker volume rm` once you are sure you do not need it.

### Update / roll back

```bash
docker compose pull && docker compose up -d           # newest :latest

# roll back to a known build: in .env
IDCM_API_IMAGE=ghcr.io/retinuesoft/idcardmanager-api:abc1234
IDCM_UI_IMAGE=ghcr.io/retinuesoft/idcardmanager-ui:abc1234
docker compose up -d
```

Database migrations that a new version adds are applied automatically when the API starts.

### Backup

```bash
docker compose exec postgres pg_dump -U postgres IDManager > idmanager-$(date +%F).sql
```

## Settings (in `.env`)

| Variable              | Needed | What it is                                                                       |
| --------------------- | ------ | -------------------------------------------------------------------------------- |
| `POSTGRES_PASSWORD`   | yes    | the database password                                                            |
| `JWT_KEY`             | yes    | secret that signs login tokens (32+ random characters); changing it logs everyone out |
| `JWT_EXPIRY_MINUTES`  | no     | how long a login lasts, from the moment of login (default `30`)                  |
| `IDCM_PUBLIC_HOST`    | no     | server IP/domain, for the API's CORS origin (defaults to `localhost`)            |
| `SEED_ADMIN_PHONE`    | no     | first Super Admin's phone (default `9943135008`)                                 |
| `SEED_ADMIN_PASSWORD` | no     | first Super Admin's password (default `Red@123`)                                 |
| `IDCM_API_IMAGE` / `IDCM_UI_IMAGE` | no | pin an image tag instead of `:latest`                                 |

The size of the downloaded card PDF's page is the API setting `Pdf__PageScale` (default 2.31 times the
card; 1 is the exact card size) - add it under `api: environment:` in `docker-compose.yml` to change it.
