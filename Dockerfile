FROM codercom/code-server:4.112.0-noble

USER root

WORKDIR /home/coder

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    bash bash-completion zsh fish \
    git less vim build-essential tmux zip unzip curl wget ca-certificates gnupg apt-transport-https \
    python3 python3-dev python3-ipykernel \
    python3-numpy python3-matplotlib python3-pandas python3-scipy python3-sympy \
    python3-postgresql python3-redis

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/lib/jvm/java-25-amazon-corretto && \
    wget -qO- https://corretto.aws/downloads/latest/amazon-corretto-25-aarch64-linux-jdk.tar.gz | \
    tar xz --strip-components=1 -C /usr/lib/jvm/java-25-amazon-corretto

COPY config/settings.json /home/coder/.local/share/code-server/User/settings.json

RUN mkdir -p /home/coder/workspace
RUN chown -R coder:coder /home/coder

USER coder

RUN echo "# utility" >> ~/.bashrc
RUN echo '[ -f "$HOME/.coderc" ] && source "$HOME/.coderc"' >> ~/.bashrc

RUN echo "# java" >> ~/.bashrc
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-25-amazon-corretto' >> ~/.bashrc
RUN echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc

RUN echo '' >> ~/.bashrc

RUN ["code-server", "--install-extension", "ms-python.python"]
RUN ["code-server", "--install-extension", "ms-toolsai.jupyter"]

EXPOSE 8080

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/home/coder/workspace"]
