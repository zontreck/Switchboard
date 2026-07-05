FROM git.zontreck.com/packages/switchboard:builder AS builder

WORKDIR /app
RUN git clone https://git.zontreck.com/Astara/Switchboard.git

WORKDIR /app/Switchboard
RUN mkdir outputs
RUN dart compile exe -o outputs/proxybot-x86_64-linux bin/bot.dart


FROM git.zontreck.com/packages/flutter:arch

WORKDIR /app
COPY --from=builder /app/Switchboard/outputs/proxybot-x86_64-linux /sbin/switchboard
RUN chmod +x /sbin/switchboard

VOLUME ["/app/data", "/app/cdn"]

ENV BOT_TOKEN NotSet
ENV SB_BOTPSK NotSet
ENV CDN_URL "https://api.systemswitchboard.com/"

ADD ./entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]