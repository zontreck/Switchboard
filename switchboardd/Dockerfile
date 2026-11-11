FROM archlinux:latest as builder

COPY . /app
WORKDIR /app
RUN dart pub get
RUN dart compile exe -o switchboardd bin/exe.dart


FROM archlinux:latest

COPY --from=builder /app/switchboardd/switchboardd /bin/switchboardd
ADD ./entry.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
VOLUME [ "/keys" ]

ENTRYPOINT [ "/bin/entrypoint" ]