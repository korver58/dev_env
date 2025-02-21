FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04

RUN apt-get update && apt-get install -y \
    curl wget git zip unzip \
    build-essential cmake \
    python3-dev python3-pip python-is-python3 \
    qtbase5-dev \
    openjdk-21-jdk \
    xalan \
    ruby \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
# install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm

RUN npm install -g \
    textlint \
    textlint-rule-preset-ja-technical-writing \
    textlint-plugin-asciidoctor

RUN gem install \
    asciidoctor \
    asciidoctor-pdf \
    asciidoctor-diagram \
    coderay

# install PMD
ARG PMD_VER=7.10.0
RUN wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VER}/pmd-dist-${PMD_VER}-bin.zip \
    && unzip pmd-dist-${PMD_VER}-bin.zip \
    && cp -r pmd-bin-${PMD_VER} /usr/local \
    && rm -rf pmd-*
ENV PATH=/usr/local/pmd-bin-${PMD_VER}/bin:${PATH}

# install cloc
ARG CLOC_VER=2.04
RUN cd /usr/local \
    && wget -O cloc.tar.gz https://github.com/AlDanial/cloc/releases/download/v${CLOC_VER}/cloc-${CLOC_VER}.tar.gz \
    && tar -zxvf cloc.tar.gz \
    && cp cloc-${CLOC_VER}/cloc /usr/local/bin \
    && rm -f cloc.tar.gz

# install graphviz
ARG GRAPHVIZ_VER=12.2.1
RUN wget https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${GRAPHVIZ_VER}/graphviz-${GRAPHVIZ_VER}.tar.gz \
    && tar -zxvf graphviz-${GRAPHVIZ_VER}.tar.gz \
    && cd graphviz-${GRAPHVIZ_VER} \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -r graphviz-*

# install doxygen
ARG DOXYGEN_VER=1.13.2
ARG DOXYGEN_VER_BAR=1_13_2
RUN wget https://github.com/doxygen/doxygen/releases/download/Release_${DOXYGEN_VER_BAR}/doxygen-${DOXYGEN_VER}.linux.bin.tar.gz \
    && tar xf doxygen-${DOXYGEN_VER}.linux.bin.tar.gz \
    && cp doxygen-${DOXYGEN_VER}/bin/doxygen /usr/local/bin \
    && rm -rf doxygen-*

# ARG UID=1001
# ARG USER=developer
# RUN useradd -m -u ${UID} ${USER}
# ENV DEBIAN_FRONTEND=noninteractive \
#     HOME=/home/${USER}
# WORKDIR ${HOME}  

USER ubuntu
WORKDIR /home/ubuntu

COPY --chown=${USER} requirements.txt ./requirements.txt
RUN python3 -m pip install --upgrade pip --break-system-packages \
    && python3 -m pip install -r requirements.txt  --no-cache-dir --break-system-packages

CMD ["/bin/bash"]
