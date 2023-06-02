FROM gcc:9.2

RUN apt-get update && apt-get install -y \
    && apt install -y netcat \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
