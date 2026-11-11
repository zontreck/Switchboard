FROM archlinux:latest as builder

COPY . .
RUN dart pub get
RUN dart compile exe -o switchboardd bin/exe.dart


FROM archlinux:latest

COPY --from=builder /app/server.new/switchboardd /bin/switchboardd
ADD ./entry.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
VOLUME [ "/keys" ]

ENTRYPOINT [ "/bin/entrypoint" ]