FROM rocker/geospatial:4.4.3

# R packages
RUN R -e "install.packages(c('renv'))"

# Python
RUN apt update && apt install -y \
    python3 python3-venv python3-pip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /home/rstudio/yo5uke.github.io/.venv && \
    /home/rstudio/yo5uke.github.io/.venv/bin/pip install --upgrade pip
ENV PATH="/home/rstudio/yo5uke.github.io/.venv/bin:$PATH"

# Quarto
ENV QUARTO_MINOR_VERSION=1.7
ENV QUARTO_PATCH_VERSION=13

RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}/quarto-${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}-linux-amd64.deb" -O quarto.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# RStudio and VSCode settings
COPY --chown=rstudio:rstudio /.config/.rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio /.config/.rstudio/rsession.conf /etc/rstudio/rsession.conf
COPY --chown=rstudio:rstudio /.vscode/_settings.json /home/rstudio/.vscode-server/data/Machine/settings.json

RUN cd /home/rstudio && mkdir .cache .TinyTeX && \
    chown -R rstudio:rstudio .cache .TinyTeX