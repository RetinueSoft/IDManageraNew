# Deploying ID Manager with Docker

Three containers, started together by `docker-compose.yml`:

| Container | What it is | Port (127.0.0.1 only) | Public (common Caddy) |
| --- | --- | --- | --- |
| `idcardmanager-postgres` | PostgreSQL 16, database **IDManager** | 5433 | - |
| `idcardmanager-api` | the .NET 8 API (also runs the migrations) | 15165 | `http://<server>:5165` |
| `idcardmanager-ui` | the Flutter web app, served by nginx | 15144 | `http://<server>:5144` |

The UI forwards `/api/` to the API itself, so open the app at `http://<server>:5144` - nothing else
has to be configured for the browser to reach the API.

The server is set up by **RetinueSoft/VpsSetup** (`/root/common`): the common Caddy serves ports 5144/5165
(`caddy/sites/idcardmanager.caddy`), one GitHub token, nightly database backups to Azure, and the settings file
`/root/common/env/idcardmanager.env`. This repo holds the app and its `deploy/update.sh`.

**How updates flow:** merge a `feature/...` branch into `release` → GitHub Actions builds
`ghcr.io/retinuesoft/idcardmanager-api` and `ghcr.io/retinuesoft/idcardmanager-ui` (tags `latest` and
`sha-<commit>`) → on the server, `sudo /root/idcardmanager/update.sh` pulls them and restarts. The server never
builds code.

## A fresh database

This app has its **own** database: `IDManager`, in its own volume (`idcardmanager_idmanager-postgres-data`). It does
not use the old app's database (`IDCardMaster`, volume `postgres-data`) or any development machine's
database, and nothing is copied over. On the first start the API:

1. creates every table (Entity Framework migrations run at startup), and
2. because the database has no users, creates one **Super Admin**:

   | Phone        | Password  |
   | ------------ | --------- |
   | `9943135008` | `Red@123` |

   (Set `SEED_ADMIN_PHONE` / `SEED_ADMIN_PASSWORD` in the settings file to use others.) This only happens on an
   empty database - it never touches an existing one. **Change the password after the first login.**

## Install (once)

`/root/common/setup.sh` installs every app listed in VpsSetup's `apps.conf`: it creates `/root/idcardmanager` and
`/root/common/env/idcardmanager.env` (with a random `JWT_KEY` and the server IP as `IDCM_PUBLIC_HOST`), then stops
so you can fill in the password:

```bash
sudo nano /root/common/env/idcardmanager.env    # POSTGRES_PASSWORD
sudo /root/idcardmanager/update.sh              # pulls the images, creates the database, starts everything
```

## Day-to-day

| Task | Command |
|---|---|
| Update to the newest version | `sudo /root/idcardmanager/update.sh` |
| Back up first, then update | `sudo /root/idcardmanager/update.sh --backup` |
| Roll back to an earlier build | `sudo /root/idcardmanager/update.sh sha-1a2b3c4` (tags: GitHub → Packages → idcardmanager-api) |
| Change a setting | `sudo nano /root/common/env/idcardmanager.env`, then `sudo /root/idcardmanager/update.sh` |
| Logs | `cd /root/idcardmanager && docker compose logs -f api ui` |
| Back up now | `sudo /root/common/backup-db.sh idcardmanager` |
| Restore a backup | `sudo /root/common/restore-db.sh idcardmanager <file>` (replaces the database) |

## Settings (`/root/common/env/idcardmanager.env`)

| Variable              | Needed | What it is                                                                       |
| --------------------- | ------ | -------------------------------------------------------------------------------- |
| `POSTGRES_PASSWORD`   | yes    | the database password                                                            |
| `JWT_KEY`             | yes    | secret that signs login tokens; `update.sh` generates one; changing it logs everyone out |
| `JWT_EXPIRY_MINUTES`  | no     | how long a login lasts, from the moment of login (default `30`)                  |
| `IDCM_PUBLIC_HOST`    | no     | server IP/domain, for the API's CORS origin (`update.sh` fills in the server IP) |
| `SEED_ADMIN_PHONE`    | no     | first Super Admin's phone (default `9943135008`)                                 |
| `SEED_ADMIN_PASSWORD` | no     | first Super Admin's password (default `Red@123`)                                 |
| `UI_HOST_PORT` / `API_HOST_PORT` / `POSTGRES_HOST_PORT` | no | ports on 127.0.0.1 (15144 / 15165 / 5433)     |
| `APP_IMAGE_TAG`       | no     | image tag in use; set by `update.sh`                                             |

The size of the downloaded card PDF's page is the API setting `Pdf__PageScale` (default 2.31 times the
card; 1 is the exact card size) - add it under `api: environment:` in `docker-compose.yml` to change it.
