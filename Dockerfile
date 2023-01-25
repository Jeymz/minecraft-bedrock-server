FROM debian:stable-slim
# Install required libraries / packages
RUN apt-get update
RUN apt-get install -y --no-install-recommends net-tools ca-certificates dumb-init curl unzip
RUN useradd -ms /bin/bash miner

ENV PORT=19132

# Expose required port
EXPOSE $PORT/udp

# Set the application directory and copy source files into container
WORKDIR /home/miner
COPY --chown=miner:miner ./src /home/miner
USER miner

HEALTHCHECK --interval=60s --timeout=10s --start-period=120s --retries=3 CMD ["netstat", "-an", "|", "grep", $PORT, ">", "/dev/null; if [ 0 != $? ]; then exit 1; fi;"]

ENTRYPOINT [ "./setup.sh" ]