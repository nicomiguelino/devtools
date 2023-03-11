# Personal Linux Development Tools

This repository contains a collection of development tools and environment for
machines running Linux.


### Installation

```bash
bash <(curl -sL https://raw.githubusercontent.com/nicomiguelino/devtools/main/install-devtools.sh)
```

### Dockerized Development Environment

You need to have Docker installed to run the commands in this section.

```bash
docker compose build && \
docker compose up -d && \
docker compose exec playground bash
```

```bash
# Run the following inside the `playground` container.
./install-devtools.sh --mode=dev
```
