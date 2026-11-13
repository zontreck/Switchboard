FROM git.zontreck.com/packages/flutter:arch as builder

COPY . /app
WORKDIR /app

RUN dart pub get
RUN dart compile exe -o switchboardd cli/switchboardd.dart


FROM archlinux:latest

COPY --from=builder /app/switchboardd /bin/switchboardd
ADD ./entry.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
VOLUME [ "/keys" ]


WORKDIR /
ENTRYPOINT [ "/bin/entrypoint" ]