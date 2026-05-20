FROM alpine:3.19 AS builder
RUN apk add --no-cache bash git jq curl
COPY . /opt/sat
RUN chmod +x /opt/sat/bin/sat

FROM alpine:3.19
LABEL maintainer="SysAdmin-Toolkit Contributors" \
      description="Lightweight SysAdmin CLI Runtime"
RUN apk add --no-cache bash coreutils procps
COPY --from=builder /opt/sat /opt/sat
ENV PATH="/opt/sat/bin:${PATH}"
WORKDIR /opt/sat
ENTRYPOINT ["sat"]
CMD ["--help"]