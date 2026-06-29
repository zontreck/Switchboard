FROM git.zontreck.com/packages/switchboard:builder AS builder

WORKDIR /app
RUN git clone https://git.zontreck.com/Astara/Switchboard.git

WORKDIR /app/Switchboard
RUN mkdir outputs
RUN dart compile exe -o outputs/server-x86_64-linux bin/server.dart


FROM git.zontreck.com/packages/flutter:arch

WORKDIR /app
COPY --from=builder /app/Switchboard/outputs/server-x86_64-linux /sbin/switchboardserver
RUN chmod +x /sbin/switchboardserver

VOLUME ["/app/data", "/app/cdn"]

ENV MARIADB_HOST 127.0.0.1
ENV MARIADB_USER switchboard
ENV MARIADB_PASS PASS
ENV MARIADB_DB switchboard
ENV USE_SQL 0
ENV BOT_TOKEN NotSet
ENV CDN_URL "https://api.systemswitchboard.com/"

ADD ./entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]