FROM rocker/geospatial:4.5.1

# R packages
RUN R -e "install.packages(c('renv'))"

# locale & Python
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      locales \
    ; \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen; \
    locale-gen ja_JP.UTF-8; \
    update-locale LANG=ja_JP.UTF-8; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
ENV LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja LC_ALL=ja_JP.UTF-8
RUN python3 -m venv /home/rstudio/.venv && \
    /home/rstudio/.venv/bin/pip install --upgrade pip && \
    chown -R rstudio:rstudio /home/rstudio/.venv
ENV PATH="/home/rstudio/.venv/bin:${PATH}"

# Quarto
ENV QUARTO_MINOR_VERSION=1.8
ENV QUARTO_PATCH_VERSION=21

RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}/quarto-${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}-linux-amd64.deb" -O quarto.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# RStudio and VSCode settings
COPY --chown=rstudio:rstudio /.config/.rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio /.config/.rstudio/rsession.conf /etc/rstudio/rsession.conf
COPY --chown=rstudio:rstudio /.vscode/_settings.json /home/rstudio/.vscode-server/data/Machine/settings.json

RUN cd /home/rstudio && mkdir .cache .TinyTeX && \
    chown -R rstudio:rstudio .cache .TinyTeX