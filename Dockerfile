FROM git.zontreck.com/packages/switchboard:builder AS builder

WORKDIR /app
RUN git clone https://git.zontreck.com/zontreck/Switchboard.git

WORKDIR /app/Switchboard
RUN chmod +x localbuild.sh && ./localbuild.sh


FROM git.zontreck.com/packages/flutter:arch

WORKDIR /app
COPY --from=builder /app/Switchboard/outputs/server-x86_64-linux /sbin/switchboardserver
RUN chmod +x /sbin/switchboardserver

VOLUME ["/app/data"]

ENV MARIADB_HOST 127.0.0.1
ENV MARIADB_USER switchboard
ENV MARIADB_PASS PASS
ENV MARIADB_DB switchboard
ENV USE_SQL 0

ENTRYPOINT ["/sbin/switchboardserver"]