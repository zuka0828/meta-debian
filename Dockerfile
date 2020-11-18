# Setup:
# (host) $ git clone -b warrior git://git.yoctoproject.org/poky.git
# (host) $ git clone -b warrior https://github.com/meta-debian/meta-debian.git poky/meta-debian
# (host) $ docker build -t deby --build-arg UID=$(id -u) --build-arg GID=$(id -g) poky/meta-debian
#
# Build:
# (host) $ docker run --rm --mount type=bind,src=$(pwd)/poky,dst=/home/deby/poky -it deby:latest
# (docker) $ . oe-init-build-env
# (docker) $ bitbake ...

FROM debian:buster

ARG USER_NAME=deby
ARG USER_PASSWORD=deby
ARG UID=1000
ARG GID=1000

ARG TEMPLATECONF=meta-debian/conf

# Set locale required by bitbake
RUN apt-get update && apt-get install -y locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8

# Install dependencies of meta-debian
COPY scripts/install-deps.sh /root/
RUN apt-get update && /root/install-deps.sh

# Create an user
RUN useradd -m -u ${UID} ${USER_NAME} && \
    echo ${USER_NAME}:${USER_PASSWORD} | chpasswd

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/poky
