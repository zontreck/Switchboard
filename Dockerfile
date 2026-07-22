FROM git.zontreck.com/packages/arch:build as builder

WORKDIR /app
RUN git clone https://git.zontreck.com/Astara/Switchboard.git

WORKDIR /app/Switchboard
RUN mkdir outputs

WORKDIR /app/Switchboard/bot
RUN dotnet build -c Release
WORKDIR /app/Switchboard/bot/Main/bin/Release/net10.0
RUN tar -cvf /app/Switchboard/outputs/proxybot-x86_64-linux.tgz .


FROM git.zontreck.com/packages/arch:base

WORKDIR /app
COPY --from=builder /app/Switchboard/outputs/proxybot-x86_64-linux.tgz /tmp/
RUN tar -xvf /tmp/proxybot-x86_64-linux.tgz && rm /tmp/*.tgz
RUN chmod +x /sbin/switchboard

VOLUME ["/app/data"]

ENV BOT_TOKEN NotSet
ENV SB_BOTPSK NotSet
ENV CDN_URL "https://api.systemswitchboard.com/"

ADD ./entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]