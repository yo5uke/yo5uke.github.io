FROM rocker/geospatial:4.4.2

RUN apt update && apt install -y \
    openssh-client \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY --chown=rstudio:rstudio /.config/.rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio /.config/.rstudio/rsession.conf /etc/rstudio/rsession.conf
COPY --chown=rstudio:rstudio /.vscode/_settings.json /home/rstudio/.vscode-server/data/Machine/settings.json

# R Package
RUN R -e "install.packages(c('renv'))"

# Python
RUN python3 -m venv /home/rstudio/.venv && \
    /home/rstudio/.venv/bin/pip install --upgrade pip

# Julia
ENV JULIA_MINOR_VERSION=1.11
ENV JULIA_PATCH_VERSION=2

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_MINOR_VERSION}/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    tar xvf julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    rm julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    ln -s $(pwd)/julia-$JULIA_MINOR_VERSION.$JULIA_PATCH_VERSION/bin/julia /usr/bin/julia

# Quarto
ENV QUARTO_MINOR_VERSION=1.6
ENV QUARTO_PATCH_VERSION=39

RUN wget -O quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}/quarto-${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}-linux-amd64.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# Package Cahce & Permission
RUN cd /home/rstudio && mkdir -p .cache .TinyTeX && \
    chown -R rstudio:rstudio .cache .TinyTeX