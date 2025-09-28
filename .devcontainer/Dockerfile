FROM rocker/geospatial:4.5.1

ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Tokyo

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip \
    fontconfig ca-certificates \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
