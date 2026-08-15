FROM git.zontreck.com/packages/arch:build as builder

WORKDIR /app/Switchboard
COPY . .

RUN git clean -xfd && git reset --hard && mkdir outputs
# This allows any branch to be built

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