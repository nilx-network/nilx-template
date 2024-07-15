FROM docker.io/paritytech/ci-unified:latest as builder

WORKDIR /nilx
COPY . /nilx

RUN cargo fetch
RUN cargo build --locked --release

FROM docker.io/parity/base-bin:latest

COPY --from=builder /nilx/target/release/nilx-template /usr/local/bin

USER root
RUN useradd -m -u 1001 -U -s /bin/sh -d /nilx nilx && \
	mkdir -p /data /nilx/.local/share && \
	chown -R nilx:nilx /data && \
	ln -s /data /nilx/.local/share/nilx-template && \
	#!!! unclutter and minimize the attack surface
	# rm -rf /usr/bin /usr/sbin && \
	# check if executable works in this container
	/usr/local/bin/nilx-template --version

USER nilx

EXPOSE 30333 9944 9615
#!!! chown -R /path/on/host
VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/nilx-template"]
