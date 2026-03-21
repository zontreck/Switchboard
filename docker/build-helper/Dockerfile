FROM git.zontreck.com/packages/flutter:arch

ADD ./build-scrpt.sh /entry
RUN chmod +x /entry

VOLUME ["/app/project/outputs", "/app/source"]

ENTRYPOINT ["/entry"]