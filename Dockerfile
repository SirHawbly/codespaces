ARG PYTHON_VERSION=3.10.12
ARG TIMEZONE=Europe/Paris

FROM python:${PYTHON_VERSION}-slim-bookworm as build
ARG TIMEZONE

ENV \
    TZ=$TIMEZONE \
    PATH="/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN python -m venv /venv

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    cmake \
    liblapack-dev \
    libopenblas-dev \
    libdsdp-dev \
    libfftw3-dev \
    libglpk-dev \
    libgsl-dev \
    && rm -rf /var/lib/apt/lists/*


FROM build as dev

RUN apt-get update && apt-get install --no-install-recommends -y \
    git openssh-client \
    bash-completion build-essential nano procps \
    gettext \
    curl gpg gpg-agent \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app
ENV PYTHONPATH /app
VOLUME [ "/app" ]

CMD [ "bash", "--login" ]


FROM python:${PYTHON_VERSION}-slim-bookworm as run
ARG TIMEZONE

COPY --from=build /venv /venv
ENV \
    TZ=$TIMEZONE \
    PATH="/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

WORKDIR /app

ENV PYTHONPATH /app

CMD [ "bash" ]
