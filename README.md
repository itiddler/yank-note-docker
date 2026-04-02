# yank-note-docker

Docker image for running [Yank Note](https://github.com/purocean/yn) in KasmVNC.

Base image: `ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble`

## Quick Start

### 1. Push to GitHub

Push this repository to your GitHub account. The GitHub Actions workflow will automatically build and push the Docker image to `ghcr.io/<your-username>/yank-note-docker`.

### 2. Run the Image

```bash
docker run -d \
  --name yank-note \
  -p 3000:3000 \
  -p 3001:3001 \
  ghcr.io/<your-username>/yank-note-docker:latest
```

Then open `http://your-host:3000` in your browser.

### 3. Build Arguments

You can customize the build with these arguments:

| Argument | Description | Default |
|----------|-------------|---------|
| `YANK_NOTE_VERSION` | Yank Note version to install (e.g., `3.87.1`) | latest release |

To build a specific version:

```bash
# via workflow dispatch input
gh workflow run build.yml -f yank_note_version=3.87.1
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TITLE` | Window title | `Yank Note` |
| `YANK_NOTE_VERSION` | Yank Note version | Build-time arg |

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Yank Note data and configuration |

## Ports

| Port | Description |
|------|-------------|
| `3000` | KasmVNC web interface |
| `3001` | Yank Note server (if exposed) |

## Notes

- The Electron app runs with `--no-sandbox` and GPU disabled for container compatibility.
- Default credentials: user `abc` / password `abc` (from baseimage-kasmvnc).
- Data is stored in `/config` volume for persistence.
