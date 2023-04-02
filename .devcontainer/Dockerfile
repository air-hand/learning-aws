FROM debian:bullseye

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TZ=Asia/Tokyo

ARG USERNAME
ARG UID
ARG GID
ARG HOMEDIR

RUN sed -ie 's!http://deb.debian.org/debian !http://ftp.jaist.ac.jp/debian !' /etc/apt/sources.list

RUN apt update && apt install -y \
    apt-file \
    make bash-completion tree jq vim git tig build-essential curl tar gzip unzip sudo tzdata man-db \
    automake autoconf libtool \
    locales-all \
    procps \
    graphviz \
    docker.io \
    python3-minimal \
    python3-pip \
    && apt-file update \
    ;

RUN groupadd --gid $GID $USERNAME \
    && useradd --uid $UID -d ${HOMEDIR} -m --gid $GID $USERNAME \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown $USERNAME:$USERNAME ${HOMEDIR} \
    ;

RUN python3 -m pip install -U pre-commit

# https://github.com/inotify-tools/inotify-tools
ENV INOTIFY_TOOLS_VER=3.22.6.0
RUN mkdir -p /usr/local/src && cd /usr/local/src \
    && curl -o inotify-tools.tar.gz -sL "https://github.com/inotify-tools/inotify-tools/archive/refs/tags/${INOTIFY_TOOLS_VER}.tar.gz" \
    && tar -zxvf inotify-tools.tar.gz \
    && cd inotify-tools-${INOTIFY_TOOLS_VER} \
    && ./autogen.sh && ./configure --prefix=/usr && make && make install \
    ;

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
RUN \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli \
    ;

RUN \
    git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv \
    && ln -s ~/.tfenv/bin/* /usr/local/bin \
    ;

ENV \
    TFLINT_VERSION=v0.41.0 \
    TFSEC_VERSION=v1.28.0

RUN \
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
    && curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash \
    && curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash \
    ;

# https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
ENV PROMPT_COMMAND='history -a' \
    HISTFILE=/commandhistory/.bash_history
RUN mkdir -p /commandhistory && chown -R $USERNAME:$USERNAME /commandhistory

COPY .terraform-version ./

RUN tfenv install

USER $USERNAME
