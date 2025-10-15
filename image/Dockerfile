FROM ubuntu:20.04

ARG RUNNER_VERSION="2.329.0"
ARG DEBIAN_FRONTEND=noninteractive

# Update and upgrade the system
RUN apt update -y && apt upgrade -y

# Add a user named docker with sudo privileges (needed for tailscale setup apparently.)
RUN useradd -m docker && \
    usermod -aG sudo docker

# Install necessary packages and add /dev/net/tun
RUN apt install -y --no-install-recommends \
    curl build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip jq git git-lfs sudo && \
    apt-get -yqq install ssh && \
    mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200 && \
    chmod 600 /dev/net/tun
# Set up the actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Change ownership to docker user and install dependencies
RUN chown -R docker /home/docker && /home/docker/actions-runner/bin/installdependencies.sh

# enable passwordless sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy the start script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Switch to docker user
USER docker

# Define the entrypoint
ENTRYPOINT ["/start.sh"]