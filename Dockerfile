FROM git.zontreck.com/packages/arch:build as builder

WORKDIR /app
RUN git clone https://git.zontreck.com/Astara/Switchboard.git

WORKDIR /app/Switchboard
RUN mkdir outputs

WORKDIR /app/Switchboard/bot
RUN dotnet build -c Release
WORKDIR /app/Switchboard/bot/Main/bin/Release/net10.0
RUN tar -cvf /app/Switchboard/outputs/proxybot-x86_64-linux.tgz .


FROM git.zontreck.com/packages/arch:build

WORKDIR /app/bin
COPY --from=builder /app/Switchboard/outputs/proxybot-x86_64-linux.tgz /tmp/
RUN tar -xvf /tmp/proxybot-x86_64-linux.tgz && rm /tmp/*.tgz

WORKDIR /app/data

VOLUME ["/app/data"]

ENV BOT_TOKEN NotSet
ENV SB_BOTPSK NotSet

ADD ./entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]