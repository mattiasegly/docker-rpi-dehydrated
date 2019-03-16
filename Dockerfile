#Using stretch because of curl SSL error on buster
FROM balenalib/rpi:stretch AS builder
RUN [ "cross-build-start" ]

RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
&& rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/lukas2511/dehydrated.git /dehydrated && \
	git clone https://github.com/aaff-se/dehydrated-loopia-api-hook.git /dehydrated/hooks/loopia && \
	chmod +x /dehydrated/hooks/loopia/loopia_hook.sh

RUN [ "cross-build-end" ]

#Using stretch because of curl SSL error on buster
FROM balenalib/rpi:stretch
RUN [ "cross-build-start" ]

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	openssl \
	libxml2-utils \
&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /dehydrated /dehydrated
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN [ "cross-build-end" ]

VOLUME /letsencrypt

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dehydrated/dehydrated", "-c", "--accept-terms"]
